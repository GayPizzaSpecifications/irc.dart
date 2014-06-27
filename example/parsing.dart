import "package:irc/parser.dart";

import "dart:io";

typedef bool CheckOutput(Message message);

Map<String, CheckOutput> inputs = {};

List<InputHostmaskGlob> glob_masks = [];

class InputHostmaskGlob {
  String pattern;
  String against;
  bool match;

  InputHostmaskGlob(this.pattern, this.against, this.match);
}

main() {
  glob_masks.add(new InputHostmaskGlob("*@ool-182e0a55.dyn.optonline.net", "blood!~blood@ool-182e0a55.dyn.optonline.net", true));
  glob_masks.add(new InputHostmaskGlob("*@oo-182e0a55.dyn.optonline.net", "blood!~blood@ool-182e0a55.dyn.optonline.net", false));
  glob_masks.add(new InputHostmaskGlob("*.optonline.net", "blood!~blood@ool-182e0a55.dyn.optonline.net", true));
  var parser = new RegexIrcParser();
  load_inputs();
  inputs.forEach((input, checker) {
    if (checker(parser.convert(input))) {
      print("Successfully Parsed '${input}'");
    } else {
      print("Failed to Parse '${input}'");
      exit(1);
    }
  });
  glob_masks.forEach((input) {
    if (new GlobHostmask(input.pattern).matches(input.against) != input.match) {
      print("ERROR: Expected matching '${input.against}' against '${input.pattern}' to be '${input.match}'");
    }
  });
}

load_inputs() {
  inputs[":Gaz492!~Gaz492@2a01:4f8:131:2288::2 PRIVMSG #FTB :shout at prog"] = (Message input) {
    return input.command == "PRIVMSG" && input.message == "shout at prog" && input.plain_hostmask == "Gaz492!~Gaz492@2a01:4f8:131:2288::2";
  };

  inputs[":availo.esper.net 354 kaendfinger 152 #computercraft ~maxlowry1"] = (Message input) {
    return input.command == "354" && input.plain_hostmask == "availo.esper.net" &&
      input.parameters.contains("152") &&
      input.parameters.contains("kaendfinger") &&
      input.parameters.contains("#computercraft") &&
      input.parameters.contains("~maxlowry1");
  };
}