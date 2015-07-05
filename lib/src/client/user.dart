part of irc.client;

/**
 * An IRC User
 */
class User extends Entity {
  /**
   * Client associated with the user
   */
  final Client client;

  @override
  String get name => nickname;

  String nickname;

  final String username;

  final String realname;

  User(this.client, this.nickname, {this.username, this.realname});

}