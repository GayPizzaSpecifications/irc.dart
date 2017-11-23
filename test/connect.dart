library irc.test.connect;

import "package:irc/legacy/client.dart";
import "faker.dart";

Environment env = createEnvironment();

void main() {
  env.server.handleCommand("CAP", (message) {
    var split = message.split(" ");
    var cmd = split[1];
    if (cmd == "LIST") {
      env.server.sendServer("CAP DartBot LS :"); // None
    } else if (cmd == "REQ") {
      env.server.sendServer("CAP DartBot ACK :${split.skip(2).join(" ").substring(1)}");
    }
  });

  env.client.register((LineReceiveEvent event) => print("Client Received: ${event.line}"));
  env.client.register((LineSentEvent event) => print("Client Sent: ${event.line}"));
  env.client.register((ReadyEvent event) => event.join("#test"));

  env.client.connect();
}
