part of irc;

/**
 * Builder for WHOIS Server Replies
 */
class WhoisBuilder {
  final String nickname;
  String username;
  String realname;
  String hostname;
  String away_message;
  List<String> channels = [];
  List<String> voice_in = [];
  List<String> op_in = [];
  List<String> owner_in = [];
  String server_name;
  String server_info;
  bool idle;
  int idle_time;
  bool server_operator;
  bool away = false;

  WhoisBuilder(this.nickname);

  @override
  String toString() {
    var instance = reflect(this);
    var sb = new StringBuffer("WHOIS(");
    var fields = instance.type.declarations.values.where((f) => f is VariableMirror && !f.isPrivate);
    var names = fields.map((f) => MirrorSystem.getName(f.simpleName));
    for (String field in names) {
      var last = names.last == field;
      var obj = instance.getField(MirrorSystem.getSymbol(field)).reflectee;
      sb
          ..write(field)
          ..write(": ")
          ..write("${obj}");
      if (!last) sb.write(", ");
    }
    sb.write(")");
    return sb.toString();
  }
}
