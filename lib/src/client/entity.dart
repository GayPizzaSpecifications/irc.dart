part of irc.client;

abstract class Entity {

  String get name;

  bool get isChannel => this is Channel;
  bool get isUser => this is User;
  bool get isServer => this is Server;

}