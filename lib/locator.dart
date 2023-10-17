import 'package:get_it/get_it.dart';
import 'pages/pages.dart';
import 'service/service.dart';

GetIt getIt = GetIt.instance;

setupServiceLocator() async {
  String authority = "type.fit";

  getIt.registerSingleton(RestService(authority: authority));
  getIt.registerLazySingleton(() => LoadingIndicatorController());
}
T locate<T extends Object>() => GetIt.instance<T>();
