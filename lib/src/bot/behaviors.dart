part of irc.bot;

class BotBehaviors {
  static EventHandler<ReadyEvent> joinOnConnect(List<String> channels) {
    return (ReadyEvent event) {
      for (var channel in channels) {
        event.join(channel);
      }
    };
  }
  
  static EventHandler<JoinEvent> sayOnJoin(String message) {
    return (JoinEvent event) {
      event.reply(message);
    };
  }
  
  static EventHandler<InviteEvent> joinOnInvite() {
    return (InviteEvent event) {
      event.join();
    };
  }
  
  static EventHandler<KickEvent> rejoinOnKick() {
    return (KickEvent event) {
      if (event.user == event.client.nickname) {
        event.client.join(event.channel.name);
      }
    };
  }
  
  static EventHandler<ReadyEvent> markAsBot({String botMode: "b"}) {
    return (ReadyEvent event) {
      event.client.mode("+${botMode}");
    };
  }
}