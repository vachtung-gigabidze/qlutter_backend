import 'package:conduit_core/conduit_core.dart';
import 'package:qlutter_backend/qlutter_backend.dart';
import 'package:qlutter_backend/utils/levels/levels_dto.dart';

class LevelController extends ResourceController {
  LevelController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getLevels() async {
    final level = await load();
    Response response = Response.ok(level);

    final aloowCORS = <String, dynamic>{"Access-Control-Allow-Origin": "*"};
    response.headers.addEntries(aloowCORS.entries);
    CORSPolicy.defaultPolicy.allowedOrigins.add("localhost:8888/recipe");
    return response;
  }

  Future<dynamic> load() async {
    String ret;
    ret = await File('./assets/classic.txt').readAsString();
    final levels = await LevelDto.openLevels(ret);

    return Future.value(levels.values.take(37).map((v) => v.toJson()).toList());
  }
}
