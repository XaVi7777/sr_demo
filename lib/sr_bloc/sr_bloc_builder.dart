import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sr_demo/sr_bloc/sr_bloc.dart';
import 'package:sr_demo/sr_bloc/stream_listener.dart';

typedef SingleResultListener<SR> = void Function(
  BuildContext context,
  SR singleResult,
);

class SrBlocBuilder<B extends SrBloc<Object?, S, SR>, S, SR>
    extends StatelessWidget {
  final B? bloc;
  final SingleResultListener<SR> onSR;
  final BlocWidgetBuilder<S> builder;
  final BlocBuilderCondition<S>? buildWhen;

  const SrBlocBuilder({
    required this.onSR,
    required this.builder,
    this.bloc,
    this.buildWhen,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamListener<SR>(
      stream: (bloc ?? context.read<B>()).singleResults,
      onData: (data) => onSR(
        context,
        data,
      ),
      child: BlocBuilder<B, S>(
        bloc: bloc,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }
}