part of irc;

/**
 * IRC Message Colors
 */
class Color {
  static final BLUE = "\u000312";
  static final RESET = "\u000f";
  static final NORMAL = "\u000f";
  static final BOLD = "\u0002";
  static final UNDERLINE = "\u001f";
  static final REVERSE = "\u0016";
  static final WHITE = "\u000300";
  static final BLACK = "\u000301";
  static final DARK_BLUE = "\u000302";
  static final DARK_GREEN = "\u000303";
  static final RED = "\u000304";
  static final BROWN = "\u000305";
  static final PURPLE = "\u000306";
  static final OLIVE = "\u000307";
  static final YELLOW = "\u000308";
  static final GREEN = "\u000309";
  static final TEAL = "\u000310";
  static final CYAN = "\u000311";
  static final MAGENTA = "\u000313";
  static final DARK_GRAY = "\u000314";
  static final LIGHT_GRAY = "\u000315";
  
  /**
   * Color can't be instantiated.
   */
  factory Color() => throw new UnsupportedError("Sorry, Color can't be instantiated");
  
  /**
   * Puts the Color String of [color] in front of [input] and ends with [end_color].
   */
  static String wrap(String input, String color, [String end_color = "reset"]) => "${forName(color)}${input}${forName(end_color)}";
  
  /**
   * Gets a Color by the name of [input]. If no such color exists it returns null.
   */
  static String forName(String input) {
    var name = input.replaceAll(" ", "_").toUpperCase();
    var field;
    try {
      field = reflectClass(Color).getField(MirrorSystem.getSymbol(name));
      if (field.reflectee is! String) {
        return null;
      }
    } catch (e) {
      return null;
    }
    return field.reflectee;
  }
 
  /**
   * Gets a Mapping of Color Names to Color Beginnings
   */
  static Map<String, String> all_colors() {
    var all = <String, String>{};
    var clazz = reflectClass(Color);
    clazz.declarations.forEach((key, value) {
      var name = MirrorSystem.getName(key).replaceAll("_", " ").toLowerCase();
      var field;
      try {
        field = clazz.getField(key);
      } catch (e) {
        return;
      }
      if (field.reflectee is String) {
        all[name] = field.reflectee;
      }
    });
    return all;
  }
}
