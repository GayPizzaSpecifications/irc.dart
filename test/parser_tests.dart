library parser_tests;

import 'package:irc/parser.dart';
import 'package:unittest/unittest.dart';

typedef dynamic InputChecker<T>(T value);

main() {
  group("Hostmask", () {
    var inputs = <String, InputChecker<Hostmask>>{
      "samrg472!~deathcraz@I.got.g-lined.cu.cc": (it) {
        if (it.nickname != "samrg472") {
          throw new Exception("nickname: ${it.nickname}");
        }

        if (it.hostname != "I.got.g-lined.cu.cc") {
          throw new Exception("hostmask: ${it.hostmask}");
        }

        if (it.identity != "~deathcraz") {
          throw new Exception("identity: ${it.identity}");
        }
        return true;
      }
    };

    for (var input in inputs.keys) {
      test(input, () {
        var hostmask = new Hostmask.parse(input);
        var checker = inputs[input];
        expect(checker(hostmask), equals(true));
      });
    }
  });

  group("Regex IrcParser", () {
    var parser = new RegexIrcParser();
    var inputs = <String, InputChecker<Message>>{
      ":OverbotDL1!~OverbotDL@74.195.31.2 PRIVMSG kaendfinger :Overbot 0.1.14": (it) {
        if (it.parameters.length != 1) {
          throw new Exception("parameters length: ${it.params.length}");
        }
        
        if (it.parameters[0] != "kaendfinger") {
          throw new Exception("target: ${it.params[1]}");
        }
        
        if (it.message != "Overbot 0.1.14") {
          throw new Exception("message: ${it.message}");
        }
        
        return true;
      }
    };
    
    for (var input in inputs.keys) {
      test(input, () {
        var checker = inputs[input];
        var message = parser.convert(input);
        expect(checker(message), equals(true));
      });
    }
  });
}