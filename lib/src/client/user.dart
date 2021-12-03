part of irc.client;

/// An IRC User
class User extends Entity {
  /// Client associated with the user
  final Client client;
  String? _username;
  String? _nickname;
  String? _realName;
  bool _isServerOperator = false;
  String? _serverName;
  String? _hostname;
  String? _serverInfo;

  /// A flag for WHOIS which determines if it is secure.
  bool secure = false;

  /// Get the user's nickname.
  String? get nickname => _nickname;

  /// Get the user's name.
  @override
  String? get name => _nickname;

  /// Get the user's username.
  String? get username => _username;

  /// Get the user's real name.
  String? get realName => _realName;

  /// The user is a Server Operator.
  bool get isServerOperator => _isServerOperator;

  /// User's hostname.
  String? get hostname => _hostname;

  /// User's Server name.
  String? get serverName => _serverName;

  /// User's Server info.
  String? get serverInfo => _serverInfo;

  /// Check if the user is away.
  Future<bool> isAway() {
    var completer = Completer.sync();

    var handler = (WhoisEvent event) {
      if (event.nickname == nickname) {
        if (!completer.isCompleted) {
          completer.complete(event.away);
        }
      }
    };

    client.register(handler);
    client.whois(nickname);

    return completer.future
        .timeout(const Duration(seconds: 5), onTimeout: () => false)
        .then((value) {
      Future(() {
        client.unregister(handler);
      });
      return value;
    });
  }

  User(this.client, this._nickname);
}
