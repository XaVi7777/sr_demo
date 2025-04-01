import 'dart:async';
import 'package:flutter/widgets.dart';

class StreamListener<T> extends StatefulWidget {
  final Stream<T> stream;
  final Widget child;
  final void Function(T event) onData;
  final Function? onError;
  final Function()? onDone;
  final bool? cancelOnError;

  const StreamListener({
    required this.stream,
    required this.child,
    required this.onData,
    this.onError,
    this.onDone,
    this.cancelOnError,
    super.key,
  });

  @override
  State<StreamListener<T>> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {
  StreamSubscription<T>? _streamSubs;
  @override
  Widget build(BuildContext context) => widget.child;
  @override
  void didUpdateWidget(covariant StreamListener<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unsubscribe();
    _subscribe();
  }
  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _subscribe();
  }
  void _subscribe() {
    _streamSubs = widget.stream.listen(widget.onData,
        onDone: widget.onDone,
        onError: widget.onError,
        cancelOnError: widget.cancelOnError);
  }
  void _unsubscribe() {
    _streamSubs?.cancel();
  }
}