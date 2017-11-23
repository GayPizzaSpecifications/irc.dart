import "package:irc/legacy/client.dart";

main() {
  print("Colors: ${Color.allColors().keys.join(", ")}");
  Color.allColors().forEach((a, b) {
    print("- ${a}: ${b}");
  });
}