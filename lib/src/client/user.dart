part of irc.client;

/**
 * An IRC User
 */
class User extends Entity {
  /**
   * Client associated with the user
   */
  final Client client;

  /**
   * Get the user's nickname.
   */
  String _nickname;

  /**
   * Get the user's nickname.
   */
  String get nickname => _nickname;

  /**
   * Get the user's name.
   */
  @override
  String get name => _nickname;

  /**
   * Get the user's username.
   */
  String _username;

  /**
   * Get the user's username.
   */
  String get username => _username;

  /**
   * Get the user's realname.
   */
  String _realname;

  /**
   * Get the user's realname.
   */
  String get realname => _realname;

  /**
   * The user is a Server Operator.
   */
  bool _isServerOperator;

  /**
   * The user is a Server Operator.
   */
  bool get isServerOperator => _isServerOperator;

  /**
   * User's hostname.
   */
  String _hostname;

  /**
   * User's hostname.
   */
  String get hostname => _hostname;

  /**
   * User's Server name.
   */
  String _serverName;

  /**
   * User's Server name.
   */
  String get serverName => _serverName;

  /**
   * User's Server info.
   */
  String _serverInfo;

  /**
   * User's Server info.
   */
  String get serverInfo => _serverInfo;

  /**
   * Check if the user is away.
   */
  Future<bool> isAway() {
    var completer = new Completer.sync();

    var handler = (WhoisEvent event) {
      if (event.nickname == nickname) {
        if (!completer.isCompleted) {
          completer.complete(event.away);
        }
      }
    };

    client.register(handler);
    client.whois(nickname);

    return completer
      .future
      .timeout(const Duration(seconds: 5), onTimeout: () => false)
      .then((value) {
      new Future(() {
        client.unregister(handler);
      });
      return value;
    });
  }

  User(this.client, this._nickname);
}
