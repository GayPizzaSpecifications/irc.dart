library parser_tests;

import 'package:irc/parser.dart';
import 'package:unittest/unittest.dart';

main() {
  group("Hostmask", () {
    var inputs = {
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
}