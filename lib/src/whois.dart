part of irc;

class WhoisBuilder {
  static final List<String> FIELDS = [
    "nickname",
    "realname",
    "hostname",
    "away_message",
    "away",
    "channels",
    "op_in",
    "voice_in",
    "server_name",
    "server_info",
    "idle",
    "idle_time",
    "server_operator"
  ];

  final String nickname;
  String username;
  String realname;
  String hostname;
  String away_message;
  List<String> channels = [];
  List<String> voice_in = [];
  List<String> op_in = [];
  String server_name;
  String server_info;
  bool idle;
  int idle_time;
  bool server_operator;
  bool away;

  WhoisBuilder(this.nickname);

  @override
  String toString() {
    var sb = new StringBuffer("WHOIS(");
    for (String field in FIELDS) {
      var last = FIELDS.last == field;
      var obj = reflect(this).getField(MirrorSystem.getSymbol(field)).reflectee;
      sb
        ..write(field)
        ..write(": ")
        ..write("${obj}");
      if (!last)
        sb.write(", ");
    }
    sb.write(")");
    return sb.toString();
  }
}