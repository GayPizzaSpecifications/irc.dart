part of irc;

/**
 * Base Class for a Client
 */
abstract class ClientBase {
  /**
   * Sends the [message] to the [target] as a message.
   *
   *      client.message("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void message(String target, String message) {
    var begin = "PRIVMSG ${target} :";

    var all = _handle_message_sending(begin, message);

    for (String msg in all) {
      send(begin + msg);
    }
  }

  /**
   * Splits the Messages if required.
   *
   * [begin] is the very beginning of the line (like 'PRIVMSG user :')
   * [input] is the message
   */
  List<String> _handle_message_sending(String begin, String input) {
    var all = [];
    if ((input.length + begin.length) > 454) {
      var max_msg = 454 - (begin.length + 1);
      var sb = new StringBuffer();
      for (int i = 0; i < input.length; i++) {
        sb.write(input[i]);
        if ((i != 0 && (i % max_msg) == 0) || i == input.length - 1) {
          all.add(sb.toString());
          sb.clear();
        }
      }
    } else {
      all = [input];
    }
    return all;
  }

  /**
   * Sends the [input] to the [target] as a notice
   *
   *      client.notice("ExampleUser", "Hello World");
   *
   * Note that this handles long messages. If the length of the message is 454
   * characters or bigger, it will split it up into multiple messages
   */
  void notice(String target, String message) {
    var begin = "NOTICE ${target} :";
    var all = _handle_message_sending(begin, message);
    for (String msg in all) {
      send(begin + msg);
    }
  }
  
  /**
   * Sends [line] to the server
   *
   *      client.send("WHOIS ExampleUser");
   *
   * Will throw an error if [line] is greater than 510 characters
   */
  void send(String line);
}
