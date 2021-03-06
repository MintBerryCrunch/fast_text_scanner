import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MethodChannelMock {
  final Duration? delay;
  final MethodChannel methodChannel;
  final Map<String, dynamic> methods;
  final log = <MethodCall>[];

  MethodChannelMock({
    required String channelName,
    this.delay,
    required this.methods,
  }) : methodChannel = MethodChannel(channelName) {
    methodChannel.setMockMethodCallHandler(_handler);
  }

  Future _handler(MethodCall methodCall) async {
    log.add(methodCall);

    if (!methods.containsKey(methodCall.method)) {
      throw MissingPluginException('No implementation found for method '
          '${methodCall.method} on channel ${methodChannel.name}');
    }

    return Future.delayed(delay ?? Duration.zero, () {
      final result = methods[methodCall.method];
      if (result is Exception) {
        throw result;
      }

      return Future.value(result);
    });
  }
}
