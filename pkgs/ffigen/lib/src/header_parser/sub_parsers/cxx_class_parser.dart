// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import '../../context.dart';
import '../clang_bindings/clang_bindings.dart' as clang_types;
import '../utils.dart';

void parseClassDeclaration(
  Context context,
  clang_types.CXCursor classCursor,
) {
  final logger = context.logger;
  final className = classCursor.spelling();
  if (className.isEmpty) {
    return;
  }

  final methodDescriptions = <String>[];

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

    final methodNumber = methodDescriptions.length + 1;
    methodDescriptions.add(
      'method $methodNumber: name=$methodName, return type=$returnType, '
      'parameters=[${args.join(', ')}]',
    );
  });

  if (methodDescriptions.isNotEmpty) {
    logger.info(
      'class name: $className has methods:\n'
      '  ${methodDescriptions.join('\n  ')}',
    );
  } else {
    logger.info('class name: $className has no CXX methods.');
  }
}
