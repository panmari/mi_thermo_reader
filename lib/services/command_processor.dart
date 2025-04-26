import 'dart:async';

abstract class CommandProcessor<T> {
  final done = Completer<T>();
  final Duration timeout;

  CommandProcessor({this.timeout = const Duration(seconds: 30)});

  // Executed when new data from the command is received.
  void onData(List<int> values);

  void onError(Object error, StackTrace trace) {
    done.completeError(error, trace);
  }

  // Callees should wait for results while data arrives. Note that this might
  // give a TimeoutException.
  Future<T> waitForResults() {
    return done.future.timeout(timeout);
  }
}
