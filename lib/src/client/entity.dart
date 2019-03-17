part of irc.client;

/// An abstract class that represents something that sends/receives messages.
abstract class Entity {
  /// Name of the entity.
  String get name;

  /// Is Channel
  bool get isChannel => this is Channel;

  /// Is User
  bool get isUser => this is User;

  /// Is Server
  bool get isServer => this is Server;
}
