part of irc.event;

/**
 * A function that handles events.
 */
typedef void EventHandlerFunction<T>(T event);

/**
 * An event filter that filters out events.
 *
 * If this function returns false, the function will be called, otherwise it will not be called.
 */
typedef bool EventFilter<T>(T event);

/**
 * A Cancelable Event
 */
abstract class Cancelable {
  bool _isCanceled;

  /**
   * Checks if this event has been canceled.
   */
  bool get isCanceled => _isCanceled;

  /**
   * Cancels this event.
   *
   * This will stop the event dispatcher from calling any other event handlers.
   */
  void cancel() {
    _isCanceled = true;
  }
}

/**
 * A Dead Event
 *
 * Dead Events are events that had no handlers called.
 */
class DeadEvent {
  final dynamic event;

  DeadEvent(this.event);
}

/**
 * The controller through which all events communicate with each other.
 */
class EventDispatcher {
  /**
   * Default Event Handler Priority
   */
  final int defaultPriority;
  final int dispatcherId;
  final _handlers = new Map<Type, List<_EventHandler>>();

  /**
   * Creates a new Event Dispatcher.
   *
   * If [defaultPriority] is specified, it will be the priority
   * that is assigned to handlers when they do not specify one.
   */
  EventDispatcher({this.defaultPriority: 10, this.dispatcherId});

  /**
   * Unregisters a [handler] from receiving events. If the specific [handler]
   * has a filter, it should be provided in order to properly unregister the
   * listener. If the specific [handler] has a priority, it should be provided as well.
   * Returns whether the [handler] was removed or not.
   */
  bool unregister(EventHandlerFunction handler, {
    EventFilter filter: _defaultFilter,
    int priority
  }) {
    if (priority == null) {
      priority = defaultPriority;
    }

    var name = _getName(handler);

    if (!_handlers.containsKey(name)) {
      return false;
    }

    var h = new _EventHandler(handler, filter, priority);
    _EventHandler fh;

    for (var mh in _handlers[name]) {
      if (mh == h) {
        fh = mh;
        break;
      }
    }

    if (fh != null) {
      _handlers[name].remove(fh);
      _handlers[name].sort((_EventHandler a, _EventHandler b) {
        return b.priority.compareTo(a.priority);
      });
      return true;
    } else {
      return false;
    }
  }

  /**
   * Registers a method so that it can start receiving events.
   *
   * A filter can be provided to determine when the [handler] will
   * be called. If the [filter] returns true then the [handler] will
   * not be called, otherwise it will be called. If no [filter] is
   * provided then the [handler] will always be called upon posting an
   * event.
   *
   * A [priority] can be provided which will specify in what order the handler will be called in.
   * The higher a priority is, the quicker it will be called in the handler list when an event is posted.
   *
   * If [always] is true, the event handler will be called even if the event was canceled.
   *
   * Returns false if [method] is already registered, otherwise true.
   */
  bool register(EventHandlerFunction handler, {
    EventFilter filter: _defaultFilter,
    int priority,
    bool always: false
  }) {
    if (priority == null) {
      priority = defaultPriority;
    }

    var name = _getName(handler);
    if (!_handlers.containsKey(name)) {
      _handlers[name] = <_EventHandler>[];
    }
    var handlers = _handlers[name];

    var h = new _EventHandler(handler, filter, priority, null, always);
    if (handlers.any((it) => it == h)) {
      return false;
    }

    handlers.add(h);
    handlers.sort((_EventHandler a, _EventHandler b) => b.priority.compareTo(a.priority));
    return true;
  }

  /**
   * Scans the object for [Subscribe] annotations and registers handlers appropriately.
   */
  bool registerHandlers(Object object) {
    var mirror = reflect(object);
    var registered = false;

    for (var method in mirror.type.instanceMembers.values) {
      var subscribes = method.metadata.where((it) => it.type.reflectedType == Subscribe).toList();
      if (subscribes.isEmpty) {
        continue;
      }

      if (subscribes.length > 1) {
        throw new Exception("${MirrorSystem.getName(mirror.type.qualifiedName)} has multiple subscribe annotations.");
      }

      var m = subscribes.first;
      var sub = m.reflectee as Subscribe;
      var params = method.parameters;

      if (params.length != 1) {
        throw new Exception("${MirrorSystem.getName(mirror.type.qualifiedName)} does not specify a valid event parameter type.");
      }

      var p = params.first;
      var name = p.type.reflectedType;
      var handler = (event) {
        mirror.invoke(method.simpleName, [event]);
      };
      var filter = sub.filter;
      var priority = sub.priority != null ? sub.priority : defaultPriority;

      if (!_handlers.containsKey(name)) {
        _handlers[name] = <_EventHandler>[];
      }

      var handlers = _handlers[name];
      var h = new _EventHandler(handler, filter, priority, object, sub.always);

      handlers.add(h);
      handlers.sort((_EventHandler a, _EventHandler b) => b.priority.compareTo(a.priority));
      registered = true;
    }

    return registered;
  }

  /**
   * Unregisters all handlers that were registered on [object].
   */
  bool unregisterHandlers(Object object) {
    var m = _handlers.values.where((h) {
      return h.any((it) => it.object == object);
    }).toList();

    if (m.isEmpty) {
      return false;
    }

    for (var n in m) {
      n.removeWhere((it) => it.object == object);
      n.sort((_EventHandler a, _EventHandler b) => b.priority.compareTo(a.priority));
    }

    return true;
  }

  /**
   * Fires an event to registered listeners. Any listeners that take the
   * specific type [event] will be called.
   *
   * If [postDeadEvent] is true, if no handlers are called for the event,
   * it will post a new event of type [DeadEvent].
   */
  bool post(dynamic event, {bool postDeadEvent: true}) {
    var name = _getName(event);

    if (!_handlers.containsKey(name)) {
      if (postDeadEvent) {
        return post(new DeadEvent(event), postDeadEvent: false);
      } else {
        return false;
      }
    }

    List<_EventHandler> handlers = _handlers[name];
    var executed = false;

    for (var handler in handlers) {
      if (handler.apply(event)) {
        executed = true;
      }
    }

    if (!executed && postDeadEvent) {
      executed = post(new DeadEvent(event), postDeadEvent: false);
    }

    return executed;
  }

  /**
   * Gets the type of the first parameter, used for posting.
   */
  Type _getName(dynamic input) {
    if (input is Function) {
      return (
        reflect(input) as ClosureMirror
      ).function.parameters.first.type.reflectedType;
    } else if (input is Type) {
      return input;
    } else {
      return input.runtimeType;
    }
  }

  static bool _defaultFilter(dynamic obj) {
    return false;
  }
}

class _EventHandler {
  final Function function;
  final Function filter;
  final int priority;
  final Object object;
  final bool always;

  _EventHandler(
    this.function,
    this.filter,
    this.priority, [
      this.object,
      this.always = false
    ]
  );

  bool apply(dynamic event) {
    if (event is Cancelable && event.isCanceled && !always) {
      return false;
    }

    if (!filter(event)) {
      function(event);
      return true;
    } else {
      return false;
    }
  }

  bool operator ==(other) => other is _EventHandler &&
    other.function == function && other.filter == filter &&
    other.priority == priority && other.object == object &&
    other.always == always;
}
