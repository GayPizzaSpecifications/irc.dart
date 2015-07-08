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
   * Get the user's name.
   */
  @override
  String get name => nickname;

  /**
   * Get the user's nickname.
   */
  String nickname;

  /**
   * Get the user's username.
   */
  final String username;

  /**
   * Get the user's realname.
   */
  final String realname;

  User(this.client, this.nickname, {this.username, this.realname});

}