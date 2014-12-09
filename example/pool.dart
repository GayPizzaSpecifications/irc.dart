import "package:irc/irc.dart";

void main() {
  var configs = [];
  for (int i = 1; i <= 400; i++) {
    configs.add(new BotConfig(
        nickname: "DartBot${i}",
        username: "DartBot",
        host: "irc.directcode.org",
        port: 6667
    ));
  }
  var pool = new ClientPool();
  configs.forEach(pool.addClient);
  
  pool.register((ConnectEvent event) {
    print(event.client.nickname + " is connected.");
  });
  
  pool.register((ReadyEvent event) => event.join("#bots"));
  
  pool.connectAll();
}