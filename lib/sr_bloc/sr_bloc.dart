import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/sr_bloc/sr_mixin.dart';

abstract class SrBloc<Event, State, SR> extends Bloc<Event, State>
    with SingleResultMixin<Event, State, SR> {
  // ignore: use_super_parameters
  SrBloc(State state) : super(state);
}