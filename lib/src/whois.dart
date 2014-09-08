part of irc;

/**
 * Builder for WHOIS Server Replies
 */
class WhoisBuilder {
  final String nickname;
  
  String username;
  String realname;
  String hostname;
  String awayMessage;
  List<String> channels = [];
  List<String> voiceIn = [];
  List<String> opIn = [];
  List<String> ownerIn = [];
  String serverName;
  String serverInfo;
  bool idle;
  int idleTime;
  bool isServerOperator;
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
