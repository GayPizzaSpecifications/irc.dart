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
  final Set<User> ops = new Set<User>();
  
  /**
   * Channel Half-Ops
   */
  final Set<User> halfops = new Set<User>();

  /**
   * Channel Voices
   */
  final Set<User> voices = new Set<User>();

  /**
   * Channel Members
   */
  final Set<User> members = new Set<User>();
  
  /**
   * Channel Owners (Not Supported on all Servers)
   */
  final Set<User> owners = new Set<User>();

  String _topic;

  /**
   * Banned Hostmasks
   */
  final List<GlobHostmask> bans = [];

  final Mode mode = new Mode.empty();

  /**
   * Channel Topic
   */
  String get topic => _topic;

  String get topicUser => _topicUser;
  
  set topic(String topic) {
    if (client.supported.containsKey("TOPICLEN")) {
      var max = client.supported['TOPICLEN'];
      if (topic.length > max) {
        throw new ArgumentError.value(topic, "length is >${max}, which is the maximum topic length set by the server.");
      }
    }
    
    client.send("TOPIC ${name} :${topic}");
  }
  
  String _topicUser;
  
  void invite(User user) {
    client.invite(user, name);
  }

  /**
   * All Users
   */
  Set<User> get allUsers {
    var all = new Set<User>()
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
  void op(User user) => setMode("+o", user);

  /**
   * Sets -o (Remove Channel Operator) mode on [user]
   */
  void deop(User user) => setMode("-o", user);

  /**
   * Sets +v (Channel Voice) mode on [user]
   */
  void voice(User user) => setMode("+v", user);

  /**
   * Sets -v (Remove Channel Voice) mode on [user]
   */
  void devoice(User user) => setMode("-v", user);

  /**
   * Sets +b (Ban) mode on [user]
   */
  void ban(User user) => setMode("+b", user);

  /**
   * Sets -b (Remove Ban) mode on [user]
   */
  void unban(User user) => setMode("-b", user);

  /**
   * Kicks [user] from channel with optional [reason].
   */
  void kick(User user, [String reason]) => client.kick(this, user, reason);

  /**
   * Sets +b on [user] then kicks [user] with the specified [reason]
   */
  void kickban(User user, [String reason]) {
    ban(user);
    kick(user, reason);
  }
  
  /**
   * Sets +h (Half-Op) mode on [user]
   */
  void hop(User user) => setMode("+h", user);
  
  /**
   * Sets -h (Remove Half-Op) mode on [user]
   */
  void dehop(User user) => setMode("-h", user);

  /**
   * Sends [msg] as a channel action.
   */
  void sendAction(String msg) => client.sendAction(name, msg);

  /**
   * Reloads the Ban List.
   */
  void reloadBans() {
    bans.clear();
    setMode("+b");
  }

  /**
   * Sets the Mode on the Channel or if the user if [user] is specified.
   */
  void setMode(String mode, [User user]) {
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
