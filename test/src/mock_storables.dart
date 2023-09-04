import 'package:simple_persistence/simple_persistence.dart';

class UserStorable extends Storable {
  final String name;

  UserStorable({
    required this.name,
  });

  @override
  Map<String, dynamic> get data => {
        'name': name,
      };

  UserStorable.fromMap(Map<String, dynamic> map) : name = map['name'];

  UserStorable copyWith({
    String? name,
  }) =>
      UserStorable(
        name: name ?? this.name,
      )..id = id;

  @override
  String toString() => 'UserStorable#$id(name: $name)';
}

class PostStorable extends Storable {
  final String title;
  final UserStorable author;

  PostStorable({
    required this.title,
    required this.author,
  });

  @override
  Map<String, dynamic> get data => {
        'title': title,
        'author': author,
      };

  PostStorable.fromMap(Map<String, dynamic> map)
      : title = map['title'],
        author = map['author'];

  PostStorable copyWith({
    String? title,
    UserStorable? author,
  }) =>
      PostStorable(
        title: title ?? this.title,
        author: author ?? this.author,
      )..id = id;

  @override
  String toString() => 'PostStorable#$id(title: $title, author: $author)';
}
