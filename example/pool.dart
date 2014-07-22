import "package:irc/irc.dart";

void main() {
  var configs = [];
  for (int i = 1; i <= 4; i++) {
    configs.add(new BotConfig(
        nickname: "DartBot${i}",
        username: "DartBot",
        host: "irc.esper.net",
        port: 6667
    ));
    configs.add(new BotConfig(
        nickname: "DartBot${i}",
        username: "DartBot",
        host: "irc.freenode.net",
        port: 6667
    ));
  }
  var pool = new ClientPool();
  configs.forEach(pool.addClient);
  pool.register((ReadyEvent event) => event.join("#directcode"));
  pool.register((LineReceiveEvent event) {
    print("[${pool.idOf(event.client)}] >> ${event.line}");
  });
  pool.register((LineSentEvent event) {
    print("[${pool.idOf(event.client)}] << ${event.line}");
  });
  pool.connectAll();
}