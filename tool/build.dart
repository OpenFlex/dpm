// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class FilteringCreateArchive implements CreateArchive {
  CreateArchive delegate;
  List<String> includes;
  List<String> excludes;

  FilteringCreateArchive(List<String> filters) {
    delegate = new CreateArchive();
    includes = [];
    excludes = [];

    for (String filter in filters) {
      if (filter == "-info.dpm") {
        throw new ToolException("The 'info.dpm' descriptor can't be excluded!");
      }

      if (filter.startsWith("-")) {
        excludes.add(filter.substring(1));
      } else if (filter.startsWith("+")) {
        includes.add(filter.substring(1));
      } else {
        throw new ToolException("Filter '$filter' isn't an exclude (starts with -) nor include (starts with +)");
      }
    }
  }

  void addFile(File file, String path) {
    var pathSeparator = new Platform().pathSeparator();

    for (final exclude in excludes) {
      if (path == exclude || path.startsWith("$exclude$pathSeparator")) {
        return;
      }
    }

    if (!includes.isEmpty()) {
      bool ok = false;
      for (final include in includes) {
        if (path == include || path.startsWith("$include$pathSeparator")) {
          ok = true;
          break;
        }
      }
      if (!ok) {
        return;
      }
    }

    delegate.addFile(file, path);
  }

  bool build(File archive) => delegate.build(archive);
}

build(List<String> args, [Directory workingDir]) {
  if (workingDir == null) {
    workingDir = new Directory(new File(".").fullPathSync());
  }

  if (args.length == 0) {
    throw new ToolException("The 'build' command needs an argument");
  }

  var archive = new CreateArchive();
  if (args.length > 1) {
    archive = new FilteringCreateArchive(args.getRange(1, args.length - 1));
  }

  String path = args[0];
  Directory dir = new Directory(path);
  if (!dir.existsSync()) {
    throw new ToolException("Directory '$path' doesn't exist");
  }

  File infoDpm = dir.file("info.dpm");
  if (!infoDpm.existsSync()) {
    throw new ToolException("The 'info.dpm' descriptor doesn't exists in '$path'");
  }

  Package pkg = new Package.fromDescriptorFile(infoDpm);

  var dirPath = new File(dir.path).fullPathSync();
  dir.fileHandler = (path) {
    var relativePath = path.replaceFirst(dirPath, "");
    if (relativePath.startsWith("/")) {
      relativePath = relativePath.substring(1);
    }
    archive.addFile(new File(path), relativePath);
  };
  dir.listSync(recursive: true);

  var archiveFile = workingDir.file("${pkg.organization}-${pkg.name}-${pkg.version}.arraz");
  archive.build(archiveFile);
}

