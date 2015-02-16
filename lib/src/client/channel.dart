part of irc.client;

/**
 * An IRC Channel
 */
class Channel {
  /**
   * Client associated with the channel
   */
  final Client client;

  /**
   * Channel Name (Including the #)
   */
  final String name;

  /**
   * Storage for data about a channel.
   * Note that this doesn't persist when the client leaves the channel.
   */
  final Map<String, dynamic> metadata;

  /**
   * Channel Operators
   */
  final Set<String> ops = new Set<String>();
  
  /**
   * Channel Half-Ops
   */
  final Set<String> halfops = new Set<String>();

  /**
   * Channel Voices
   */
  final Set<String> voices = new Set<String>();

  /**
   * Channel Members
   */
  final Set<String> members = new Set<String>();
  
  /**
   * Channel Owners (Not Supported on all Servers)
   */
  final Set<String> owners = new Set<String>();

  String _topic;

  /**
   * Banned Hostmasks
   */
  final List<GlobHostmask> bans = [];

  /**
   * Channel Topic
   */
  String get topic => _topic;

  set topic(String topic) {
    if (client.supported.containsKey("TOPICLEN")) {
      var max = client.supported['TOPICLEN'];
      if (topic.length > max) {
        throw new ArgumentError.value(topic, "length is >${max}, which is the maximum topic length set by the server.");
      }
    }
    
    client.send("TOPIC ${name} :${topic}");
  }
  
  void invite(String user) {
    client.invite(user, name);
  }

  /**
   * All Users
   */
  Set<String> get allUsers {
    var all = new Set<String>()
        ..addAll(ops)
        ..addAll(voices)
        ..addAll(members)
        ..addAll(owners)
        ..addAll(halfops);
    return all;
  }

  /**
   * Creates a new channel associated with [client] named [name].
   */
  Channel(this.client, this.name) : metadata = {};

  /**
   * Sends [message] as a channel message
   */
  void sendMessage(String message) => client.sendMessage(name, message);

  /**
   * Sends [message] as a channel notice
   */
  void sendNotice(String message) => client.sendNotice(name, message);

  /**
   * Sets +o (Channel Operator) mode on [user]
   */
  void op(String user) => mode("+o", user);

  /**
   * Sets -o (Remove Channel Operator) mode on [user]
   */
  void deop(String user) => mode("-o", user);

  /**
   * Sets +v (Channel Voice) mode on [user]
   */
  void voice(String user) => mode("+v", user);

  /**
   * Sets -v (Remove Channel Voice) mode on [user]
   */
  void devoice(String user) => mode("-v", user);

  /**
   * Sets +b (Ban) mode on [user]
   */
  void ban(String user) => mode("+b", user);

  /**
   * Sets -b (Remove Ban) mode on [user]
   */
  void unban(String user) => mode("-b", user);

  /**
   * Kicks [user] from channel with optional [reason].
   */
  void kick(String user, [String reason]) => client.kick(this, user, reason);

  /**
   * Sets +b on [user] then kicks [user] with the specified [reason]
   */
  void kickban(String user, [String reason]) {
    ban(user);
    kick(user, reason);
  }
  
  /**
   * Sets +h (Half-Op) mode on [user]
   */
  void hop(String user) => mode("+h", user);
  
  /**
   * Sets -h (Remove Half-Op) mode on [user]
   */
  void dehop(String user) => mode("-h", user);

  /**
   * Sends [msg] as a channel action.
   */
  void sendAction(String msg) => client.sendAction(name, msg);

  /**
   * Reloads the Ban List.
   */
  void reloadBans() {
    bans.clear();
    mode("+b");
  }

  /**
   * Sets the Mode on the Channel or if the user if [user] is specified.
   */
  void mode(String mode, [String user]) {
    if (user == null) {
      client.send("MODE ${name} ${mode}");
    } else {
      client.send("MODE ${name} ${mode} ${user}");
    }
  }

  /**
   * Compares [object] to this. Only true if channels names are equal.
   */
  bool operator ==(Object object) => object is Channel && identical(client, object.client) && this.name == object.name;
}