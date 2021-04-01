import 'package:flutter/material.dart';
import 'package:sidekick/dto/channel.dto.dart';

class MasterDto extends ChannelDto {
  /// Latest version of the channel

  MasterDto({
    @required String name,
    @required bool isInstalled,
    @required needSetup,
    @required String sdkVersion,
  }) : super(
          name: name,
          isInstalled: isInstalled,
          needSetup: needSetup,
          sdkVersion: sdkVersion,
          release: null,
          currentRelease: null,
        );
}
