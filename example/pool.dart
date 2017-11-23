import "package:irc/legacy/client.dart";

void main(List<String> args) {
  if (args.isEmpty) {
    print("usage: pool <server>");
    return;
  }
  
  var server = args[0];
  
  var configs = [];
  for (int i = 1; i <= 10; i++) {
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

  pool.register((LineReceiveEvent event) {
    print(">> " + event.line);
  });
  
  pool.register((ReadyEvent event) {
    event.join("#directcode");
  });
  
  pool.connectAll();
  print("Starting Connections");
}
