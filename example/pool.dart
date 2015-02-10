import "package:irc/client.dart";

void main(List<String> args) {
  if (args.isEmpty) {
    print("usage: pool <server>");
    return;
  }
  
  var server = args[0];
  
  var configs = [];
  for (int i = 1; i <= 5000; i++) {
    configs.add(new Configuration(
        nickname: "DartBot${i}",
        username: "DartBot",
        host: server,
        port: 6667
    ));
  }
  var pool = new ClientPool();
  configs.forEach(pool.addClient);
  
  pool.register((ConnectEvent event) {
    print(event.client.nickname + " is connected.");
  });
  
  pool.register((ReadyEvent event) {
    for (var i = 1; i <= 5000; i++) {
      event.join("#chan${i}");
      event.client.sendMessage("#chan${i}", "bitches");
    }
  });
  
  pool.connectAll();
}