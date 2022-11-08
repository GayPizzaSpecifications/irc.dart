import 'package:irc/client.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    print('usage: pool <server>');
    return;
  }

  var server = args[0];

  var configs = <Configuration>[];
  for (var i = 1; i <= 10; i++) {
    configs.add(Configuration(
        nickname: 'DartBot${i}',
        username: 'DartBot',
        host: server,
        port: 6667));
  }
  var pool = ClientPool();
  configs.forEach(pool.addClient);

  pool.register((ConnectEvent event) {
    print('${event.client.nickname} is connected.');
  });

  pool.register((LineReceiveEvent event) {
    print('>> ${event.line}');
  });

  pool.register((ReadyEvent event) {
    event.join('#mysticlgbt');
  });

  pool.connectAll();
  print('Starting Connections');
}
