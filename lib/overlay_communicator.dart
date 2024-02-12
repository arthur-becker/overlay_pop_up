import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OverlayCommunicator {
  late final BasicMessageChannel _messageChannel;
  final StreamController _mssgController = StreamController.broadcast();

  OverlayCommunicator._(OverlayCommunicatorType type) {
    late String channelName;
    if (type == OverlayCommunicatorType.overlay) {
      channelName = 'overlay_message_channel';
    } else if (type == OverlayCommunicatorType.app) {
      channelName = 'app_message_channel';
    } else {
      throw Exception('Invalid OverlayCommunicatorType');
    }
    _messageChannel = BasicMessageChannel(channelName, JSONMessageCodec());
  }

  static OverlayCommunicator? _instance;
  static OverlayCommunicator get instance {
    if (_instance == null) {
      throw Exception('OverlayCommunicator is not initialized.'
          ' Call OverlayCommunicator.init() first.');
    }
    return _instance!;
  }

  ///
  /// Initialize the [OverlayCommunicator].
  /// Set [isOverlay] to `true` if the [OverlayCommunicator]
  /// is being initialized in the overlay. Otherwise, set it to `false`.
  ///
  static void init(OverlayCommunicatorType communicatorType) {
    if (_instance != null) {
      throw Exception('OverlayCommunicator is already initialized');
    }

    _instance = OverlayCommunicator._(communicatorType);
  }

  Future<void> send(dynamic data) async {
    await _messageChannel.send(data);
  }

  Stream<dynamic>? get onMessage {
    _messageChannel.setMessageHandler((mssg) async {
      if (_mssgController.isClosed) return '';
      _mssgController.add(mssg);
      return mssg;
    });

    if (_mssgController.isClosed) return null;
    return _mssgController.stream;
  }

  ///
  /// drain and close data stream controller
  ///
  void stopDataListener() {
    try {
      _mssgController.stream.drain();
      _mssgController.close();
    } catch (e) {
      debugPrint(
          '[OverlayCommunicator] Something went wrong when close overlay pop up: $e');
    }
  }
}

enum OverlayCommunicatorType {
  overlay,
  app,
}
