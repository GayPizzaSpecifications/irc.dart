part of irc.client;

/// Builder for WHOIS Server Replies
class WhoisBuilder {
  final String nickname;

  String username;
  String realName;
  String hostname;
  String awayMessage;
  List<String> channels = [];
  List<String> voiceIn = [];
  List<String> opIn = [];
  List<String> ownerIn = [];
  List<String> halfOpIn = [];
  String serverName;
  String serverInfo;
  bool idle = false;
  int idleTime;
  bool isServerOperator = false;
  bool away = false;

  DateTime _createTimestamp;

  bool secure = false;
  String secureConnectionInfo;

  DateTime get created => _createTimestamp;

  WhoisBuilder(this.nickname);

  @override
  String toString() {
    return [
      "Nickname: ${nickname}",
      "Username: ${username}",
      "Realname: ${realName}",
      "Hostname: ${hostname}",
      "Away Message: ${awayMessage}",
      "Away: ${away}",
      "Channels: ${channels.join(',')}",
      "Voice In: ${voiceIn.join(',')}",
      "Op In: ${opIn.join(',')}",
      "Owner In: ${ownerIn.join(',')}",
      "Half Op In: ${halfOpIn.join(',')}",
      "Server Name: ${serverName}",
      "Server Info: ${serverInfo}",
      "Idle: ${idle}",
      "Idle Time: ${idleTime}",
      "Is Server Operator: ${isServerOperator}"
    ].where((line) => !line.endsWith("null")).join("\n");
  }
}
