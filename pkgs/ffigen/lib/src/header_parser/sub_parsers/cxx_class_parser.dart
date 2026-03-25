// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

/// Parses a C++ class declaration and logs its methods.
///sample implementation for C++ parser support: discover classes,
/// inspect methods, and print method signatures.
void parseClassDeclaration(Context context, clang_types.CXCursor classCursor) {
  final logger = context.logger;
  final className = classCursor.spelling();
  if (className.isEmpty) {
    return;
  }

  final methodSignatures = <String>[];

  classCursor.visitChildren((child) {
    final kind = clang.clang_getCursorKind(child);
    if (kind != clang_types.CXCursorKind.CXCursor_CXXMethod) {
      return;
    }

    final methodName = child.spelling();
    final returnType = clang.clang_getCursorResultType(child).spelling();
    final argCount = clang.clang_Cursor_getNumArguments(child);
    final args = <String>[];
    for (var i = 0; i < argCount; i++) {
      final arg = clang.clang_Cursor_getArgument(child, i);
      final argType = arg.type().spelling();
      final argName = arg.spelling();
      args.add(argName.isEmpty ? argType : '$argType $argName');
    }

    methodSignatures.add('$returnType $methodName(${args.join(', ')})');
  });

  if (methodSignatures.isNotEmpty) {
    logger.info(
      'Parsed C++ class `$className` with methods:\n'
      '  - ${methodSignatures.join('\n  - ')}',
    );
  }
}
