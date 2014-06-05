part of DartBot;

class Events {
    static final EventType<ConnectEvent> Connect = new EventType<ConnectEvent>();
    static final EventType<ReadyEvent> Ready = new EventType<ReadyEvent>();
    static final EventType<LineEvent> Line = new EventType<LineEvent>();
    static final EventType<SendEvent> Send = new EventType<SendEvent>();
}

abstract class Event {
    IRCClient client;
}

class ConnectEvent extends Event {
    ConnectEvent(IRCClient client) {
        this.client = client;
    }
}

class ReadyEvent extends Event {
    ReadyEvent(IRCClient client) {
        this.client = client;
    }
}

class LineEvent extends Event {
    String command;
    String prefix;
    List<String> params;
    IRCParser.Message message;

    LineEvent(IRCClient client, this.command, this.prefix, this.params, this.message) {
        this.client = client;
    }
}

class SendEvent extends Event {
    String line;

    SendEvent(IRCClient client, this.line) {
        this.client = client;
    }
}