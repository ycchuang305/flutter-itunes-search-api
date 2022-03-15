#!/bin/sh
lcov --remove coverage/lcov.info 'lib/*/*.freezed.dart' 'lib/*/*.g.dart' 'lib/*/*.config.g.dart' 'lib/*/*.part.dart' 'lib/*/*.gr.dart' -o coverage/lcov.info