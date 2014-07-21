library parser_tests;

import 'package:irc/parser.dart';
import 'package:unittest/unittest.dart';

typedef dynamic InputChecker<T>(T value);

main() {
  group("Hostmask", () {
    var inputs = <String, InputChecker<Hostmask>>{
      "samrg472!~deathcraz@I.got.g-lined.cu.cc": (Hostmask it) {
        expect(it.nickname, equals("samrg472"), reason: "nickname should be 'samrg472'");
        expect(it.identity, equals("~deathcraz"), reason: "identity should be '~deathcraz'");
        expect(it.hostname, equals("I.got.g-lined.cu.cc"), reason: "hostname should be 'I.got.g-lined.cu.cc'");
      }
    };

    for (var input in inputs.keys) {
      test(input, () {
        var hostmask = new Hostmask.parse(input);
        var checker = inputs[input];
        checker(hostmask);
      });
    }
  });

  group("Regex IrcParser", () {
    var parser = new RegexIrcParser();
    var inputs = <String, InputChecker<Message>>{
      ":OverbotDL1!~OverbotDL@74.195.31.2 PRIVMSG kaendfinger :Overbot 0.1.14": (Message it) {
        expect(it.hostmask.nickname, equals("OverbotDL1"), reason: "hostmask nickname should be 'OverbotDL1'");
        expect(it.hostmask.hostname, equals("74.195.31.2"), reason: "hostmask hostname should be '74.195.31.2'");
        expect(it.hostmask.identity, equals("~OverbotDL"), reason: "identity should be '~OverbotDL'");
        expect(it.parameters.length, equals(1), reason: "there should be one parameter");
        expect(it.parameters[0], equals("kaendfinger"), reason: "first parameter should be 'kaendfinger'");
        expect(it.message, equals("Overbot 0.1.14"), reason: "message should be 'Overbot 0.1.14'");
      },
      "@test=super;single :test!me@test.ing FOO bar baz quux :This is a test": (Message it) {
        expect(it.tags, isNotNull, reason: "tags should not be null");
        expect(it.tags, containsPair("test", "super"), reason: "tag 'test' should be 'super'");
        expect(it.command, equals("FOO"), reason: "command should be 'FOO'");
        expect(it.parameters.length, equals(3), reason: "there should be 3 parameters");
        expect(it.message, equals("This is a test"), reason: "message should be 'This is a test'");
      }
    };

    for (var input in inputs.keys) {
      test(input, () {
        var checker = inputs[input];
        var message = parser.convert(input);
        checker(message);
      });
    }
  });
}
