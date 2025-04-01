import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

mixin SingleResultMixin<Event, State, SR> on Bloc<Event, State>
    implements SingleResultProvider<SR>, SingleResultEmmiter<SR> {
  @protected
  final StreamController<SR> _srController = StreamController.broadcast();

  @override
  Stream<SR> get singleResults => _srController.stream;

  @override
  void addSr(SR sr) {
    final observer = Bloc.observer;
    if (observer is SrBlocObserver) observer.onSr(this, sr);
    if (!_srController.isClosed) _srController.add(sr);
  }

  @override
  Future<void> close() {
    _srController.close();

    return super.close();
  }
}

abstract class SingleResultProvider<SingleResult> {
  Stream<SingleResult> get singleResults;
}

abstract class SingleResultEmmiter<SingleResult> {
  void addSr(SingleResult sr);
}

class SrBlocObserver<SR> extends BlocObserver {
  @protected
  @mustCallSuper
  void onSr(
    Bloc<dynamic, dynamic> bloc,
    SR sr,
  ) {}
}