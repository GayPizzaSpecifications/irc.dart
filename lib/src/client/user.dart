part of irc.client;

/**
 * An IRC User
 */
class User {
  /**
   * Client associated with the user
   */
  final Client client;

  String nickname;

  final String username;

  final String realname;

  User(this.client, this.nickname, {this.username, this.realname});
}