import 'package:shelf_router/shelf_router.dart';
import 'controller.dart';

Router jsonRpcHttpRouter = Router();

void opentoolRoutes(Controller controller) {
  jsonRpcHttpRouter.get('/version', controller.getVersion);
  jsonRpcHttpRouter.post('/call', controller.call);
  jsonRpcHttpRouter.get('/load', controller.load);
}