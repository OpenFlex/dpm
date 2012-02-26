// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

#import('dart:io');
#import('../dpm.dart');
#import('dpm-tool.dart');

intro() {
  print("""
DPM, the Dart Package Manager
Usage: dpm <command> [<argument> ...]

Commands for working with a repository:
   install <pkg> [...]            install packages from remote repo
   remove <pkg> [...]             remove installed packages
   search <what>                  find packages in remote repo
   show <pkg>                     shows detailed info about a package
   list [<what>]                  list installed packages

Commands for creating packages:
   infer <directory>              automatically generate info.dpm if possible
   build <directory>              build an .arraz package of a directory
   deploy <pkg file> [...]        install an .arraz package(s) to local repo
   publish <pkg file> [...]       publish an .arraz package(s) to remote repo

General commands:
   help                           show general help for DPM
   help <command>                 show help for specified command
   version                        show some informations about DPM
""");
}

generalHelp() {
}

helpForCommand(cmd) {
}

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
    "deploy": nyi,
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

