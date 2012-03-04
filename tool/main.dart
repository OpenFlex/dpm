// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

#import('dart:io');
#import('../dpm.dart');
#import('dpm-tool.dart');
#source('help.dart');

help(args) => args.length == 0 ? generalHelp() : helpForCommand(args[0]);

version(args) {
  print("""
DPM, the Dart Package Manager
Core library version $dpmVersion
Tool version $dpmToolVersion
Licensed under BSD-style license
""");
}

nyi(args) {
  print("Not yet implemented");
}

main() {
  var commands = {
    "help": help,
    "version": version,

    "install": nyi,
    "remove": nyi,
    "search": nyi,
    "show": nyi,
    "list": nyi,

    "infer": infer,
    "build": build,
    "deploy": deploy,
    "publish": nyi
  };

  var args = new Options().arguments;
  if (args.length == 0) {
    intro();
    return;
  }

  var first = args[0];
  var rest = args.getRange(1, args.length - 1);

  if (!commands.containsKey(first)) {
    intro();
    return;
  }

  try {
    commands[first](rest);
  } catch (DpmException e) {
    print("$e");
  }
}

