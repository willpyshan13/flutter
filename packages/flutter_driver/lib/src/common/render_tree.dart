// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'message.dart';

/// A Flutter Driver command that requests a string representation of the render tree.
class GetRenderTree extends Command {
  /// Create a command to request a string representation of the render tree.
  const GetRenderTree({ Duration timeout }) : super(timeout: timeout);

  /// Deserializes this command from the value generated by [serialize].
  GetRenderTree.deserialize(Map<String, String> json) : super.deserialize(json);

  @override
  String get kind => 'get_render_tree';
}

/// A string representation of the render tree, the result of a
/// [FlutterDriver.getRenderTree] method.
class RenderTree extends Result {
  /// Creates a [RenderTree] object with the given string representation.
  const RenderTree(this.tree);

  /// String representation of the render tree.
  final String tree;

  /// Deserializes the result from JSON.
  static RenderTree fromJson(Map<String, dynamic> json) {
    return RenderTree(json['tree'] as String);
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
    'tree': tree,
  };
}
