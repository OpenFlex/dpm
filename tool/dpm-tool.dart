// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

#library('dpm-tool');

#import('dart:io');
#import('../dpm.dart');
#import('../../dartlings/files.dart');

#source('infer.dart');

final dpmToolVersion = "0.1-dev";

class ToolException extends DpmException {
  ToolException(String message) : super(message);
}

