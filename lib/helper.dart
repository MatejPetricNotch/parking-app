// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DirectoryItem {
  final String? owner;
  final String? description;
  final String? phone;
  final String? registration;
  DirectoryItem({
    this.owner,
    this.description,
    this.phone,
    this.registration,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'owner': owner,
      'description': description,
      'phone': phone,
      'registration': registration,
    };
  }

  factory DirectoryItem.fromMap(Map<String, dynamic> map) {
    return DirectoryItem(
      owner: map['owner'] != null ? map['owner'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      phone: map['phone'] != null ? map['phone'] as String : null,
      registration:
          map['registration'] != null ? map['registration'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DirectoryItem.fromJson(String source) =>
      DirectoryItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
