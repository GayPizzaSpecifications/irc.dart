import "package:irc/irc.dart";

main() {
  print("Colors: ${Color.all_colors().keys.join(", ")}");
  Color.all_colors().forEach((a, b) {
    print("- ${a}: ${b}");
  });
}