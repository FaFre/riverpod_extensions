import 'package:riverpod/riverpod.dart';
import 'package:riverpod_extensions/src/extensions/provider_container_extensions.dart';
import 'package:test/test.dart';

final provider = FutureProvider.autoDispose.family<int, int>((ref, input) =>
    Future.delayed(const Duration(milliseconds: 50)).then((value) {
      ref.maintainState = true;
      return input * 2;
    }));

void main() {
  test('subscribeFuture', () async {
    final container = ProviderContainer();

    final first = container.subscribeFuture(provider(1));
    final second = container.subscribeFuture(provider(1));

    expect(await container.subscribeFuture(provider(1)), equals(2));
    expect(await first, equals(2));
    expect(await second, equals(2));
  });
}
