import 'dart:async';

import 'package:riverpod/riverpod.dart';

extension ProviderContainerExtension on ProviderContainer {
  Future<T> subscribeFuture<T>(dynamic provider) {
    final currentState = read(provider);
    if (currentState is AsyncData) {
      return Future<T>.value(currentState.value);
    }

    return readListen(provider);
  }

  Future<T> readListen<T>(dynamic provider) {
    final completer = Completer<T>();

    ProviderSubscription? listener;

    //Future that closes the listener before returning
    //register before listener to catch errors
    final returnFuture = completer.future.then((val) {
      listener?.close();
      return val;
    }, onError: (o, s) {
      listener?.close();
      return Future<T>.error(o, s);
    });

    //register listener
    listener = listen(
      provider,
      (_, state) {
        if (state is AsyncData) {
          completer.complete(state.value);
        } else if (state is AsyncError) {
          completer.completeError(state.error, state.stackTrace);
        }
      },
      onError: (o, s) {
        completer.completeError(o, s);
      },
    );

    return returnFuture;
  }
}
