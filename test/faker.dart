library irc.test.faker;

import "dart:async";
import "package:irc/legacy/client.dart";

typedef void CommandHandler(Message message);

class FakeServer {
  RegexIrcParser parser = new RegexIrcParser();
  FakeServerConnection connection;
  StreamController<String> controller = new StreamController<String>.broadcast();
  StreamController<String> inputs = new StreamController<String>.broadcast();
  Stream<String> get messages => inputs.stream;

  FakeServer() {
    connection = new FakeServerConnection(this);

    controller.stream.listen((msg) {
      print("Server Sent: ${msg}");
    });

    handleCommand("USER", (String line) {
      kickOff();
    });

    handleCommand("CAP", (message) {
      var split = message.split(" ");
      var cmd = split[1];
      if (cmd == "LIST") {
        sendServer("CAP DartBot LS :"); // None
      } else if (cmd == "REQ") {
        sendServer("CAP DartBot ACK :${split.skip(2).join(" ").substring(1)}");
      }
    });

    handleCommand("JOIN", (message) {
      sendClient("JOIN ${message.split(" ").last}");
    });

    handleCommand("PING", (String line) {
      var id = line.split(" ")[1].substring(1);
      sendServer("PONG :${id}");
    });
  }

  void kickOff() {
    sendServer("001 DartBot :Welcome!");
    sendServer("005 PREFIX=(ov)@+ NETWORK=FakeNet");
    sendServer("372 DartBot :This is the MOTD.");
    sendServer("376 DartBot :Done with MOTD.");
  }

  void onConnect() {
    sendServer("PING :ABCD");
  }

  void process(String line) {
    print("Server Received: ${line}");
    inputs.add(line);
  }

  void handleCommand(String cmd, void handle(String input)) {
    messages.where((it) => it.startsWith("${cmd} ")).listen(handle);
  }

  void sendServer(String line) {
    controller.add(":fake.server ${line}");
  }

  void sendUser(String nick, String line) {
    controller.add(":${nick}!fake@fake.host ${line}");
  }

  void sendClient(String line) {
    controller.add(":DartBot!DartBot@fake.client ${line}");
  }
}

class FakeServerConnection extends IrcConnection {
  final FakeServer server;

  FakeServerConnection(this.server);

  @override
  Future connect(Configuration config) async {
    server.kickOff();

    return true;
  }

  @override
  Future disconnect() async {
    return true;
  }

  @override
  Stream<String> lines() {
    return server.controller.stream;
  }

  @override
  void send(String line) {
    server.process(line);
  }
}

class Environment {
  Client client;
  FakeServer server;
}

Environment createEnvironment() {
  var server = new FakeServer();
  var client = new Client(new Configuration(), connection: server.connection);
  var env = new Environment();
  env.server = server;
  env.client = client;
  return env;
}
