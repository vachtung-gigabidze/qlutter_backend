import 'package:conduit_core/conduit_core.dart';

import '../model/user_progress.dart';

class UserProgressController extends ManagedObjectController<UserProgress> {
  UserProgressController(ManagedContext context) : super(context);
}

class BestProgressController extends ResourceController {
  BestProgressController(this.context) : super();

  final ManagedContext context;

  @Operation.get()
  Future<Response> getBestOfBest() async {
    final query = Query<UserProgress>(context);

    final userProgress = await query.fetch();

    final m = <int, UserProgress>{};

    userProgress.sort((a, b) => a.levelId!.compareTo(b.levelId!));

    for (UserProgress e in userProgress) {
      if (m[e.levelId] == null) {
        m[e.levelId!] = e;
      } else {
        final p = m[e.levelId];
        if (p != null && p.seconds != null && e.seconds != null) {
          if (e.seconds! < p.seconds!) {
            m[e.levelId!] = e;
          }
        }
      }
    }
    // final filterRecipe = userProgress
    //     .where((r) => r.favoriteRecipes!.any((f) => f.user?.id == id))
    //     .toList();
    final Response response = Response.ok(m.values.toList());

    return response;
  }
}
