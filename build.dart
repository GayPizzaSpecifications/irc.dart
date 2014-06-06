import "src/irc.dart";

import "dart:mirrors";

void main(List<String> args) {
    currentMirrorSystem().findLibrary(new Symbol("irc"));
}