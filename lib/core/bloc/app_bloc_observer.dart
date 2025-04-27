import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event'); // Consider using proper logging
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print(
      '${bloc.runtimeType} $error $stackTrace',
    ); // Consider using proper logging
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change'); // Consider using proper logging
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition'); // Consider using proper logging
  }
}
