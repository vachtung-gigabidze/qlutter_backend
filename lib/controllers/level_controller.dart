import 'package:conduit_core/conduit_core.dart';
import 'package:qlutter_backend/qlutter_backend.dart';
import 'package:qlutter_backend/utils/levels/levels_dto.dart';

class LevelController extends ResourceController {
  LevelController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getLevels() async {
    final level = await load();
    Response response;
    response = Response.ok(level);

    final alowCORS = <String, dynamic>{"Access-Control-Allow-Origin": "*"};
    response.headers.addEntries(alowCORS.entries);
    CORSPolicy.defaultPolicy.allowedOrigins.add("localhost:8888/levels");
    return response;
  }

  Future<dynamic> load() async {
    String ret;
    ret = await File('./assets/private/classic.txt').readAsString();
    final levels = await LevelDto.openLevels(ret);

    return Future.value(levels.values.take(51).map((v) => v.toJson()).toList());
  }
}
