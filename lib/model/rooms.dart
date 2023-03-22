import 'package:conduit_core/conduit_core.dart';

class Rooms extends ManagedObject<_Rooms> implements _Rooms {}

class _Rooms {
  @primaryKey
  int? id;

  @Column()
  DateTime? datetime;

  @Column()
  String? roomId;

  @Column()
  String? roomName;
}
