import 'package:conduit_core/conduit_core.dart';
import 'user.dart';

class Comment extends ManagedObject<_Comment> implements _Comment {}

class _Comment {
  @primaryKey
  int? id;

  @Relate(#comments)
  User? user;

  @Column()
  int? levelId;

  @Column()
  String? text;

  @Column(nullable: true)
  String? photo;

  @Column()
  DateTime? datetime;
}
