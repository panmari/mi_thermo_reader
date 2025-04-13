import 'dart:async';

abstract class CommandProcessor<T> {
  final done = Completer<T>();

  // Executed when new data from the command is received.
  void onData(List<int> values);

  void onError(Object error, StackTrace trace) {
    done.completeError(error, trace);
  }

  Future<T> waitForResults() {
    return done.future;
  }
}
