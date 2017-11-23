part of irc.event;

/**
 * Subscribes the method that this is annotated with to the event type of the first parameter.
 *
 * See [EventDispatcher.registerHandlers].
 */
class Subscribe {
  final int priority;
  final EventFilter filter;
  final bool always;

  const Subscribe({
    this.priority,
    this.filter: EventDispatcher._defaultFilter,
    this.always: false
  });
}
