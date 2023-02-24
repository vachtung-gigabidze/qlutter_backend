import 'package:conduit_core/conduit_core.dart';
import 'user.dart';

class UserProgress extends ManagedObject<_UserProgress>
    implements _UserProgress {}

class _UserProgress {
  @primaryKey
  int? id;

  @Relate(#progress)
  User? user;

  @Column()
  int? levelId;

  @Column()
  int? steps;

  @Column()
  DateTime? datetime;
}
