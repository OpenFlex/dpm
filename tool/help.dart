// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

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
  print("general help"); // TODO
}

helpForCommand(cmd) {
  print("help for command $cmd"); // TODO
}

