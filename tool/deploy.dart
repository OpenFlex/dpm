// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

deploy(List<String> args, [FilesystemRepository repo]) {
  if (repo == null) {
    repo = new LocalUserRepository();
  }

  if (args.length == 0) {
    throw new ToolException("The 'deploy' command needs at least one argument");
  }

  // check first -- all packages must exist and have the descriptor
  for (String pkgPath in args) {
    var pkg = new File(pkgPath);
    if (!pkg.existsSync()) {
      throw new ToolException("The package '$pkgPath' doesn't exist");
    }

    var pkgArchive = new ExtractArchive(pkg);
    if (!pkgArchive.findEntry("info.dpm")) {
      throw new ToolException("The package '$pkgPath' doesn't containt the 'info.dpm' descriptor");
    }
  }

  for (String pkgPath in args) {
    var pkgArchive = new ExtractArchive(new File(pkgPath));

    Directory temp = new Directory(repo.root.path).subdirectory(["temp"]);
    temp.createTempSync();
    pkgArchive.extractEntry("info.dpm", temp);

    Package pkg = new Package.fromDescriptorFile(temp.file("info.dpm"));
    pkgArchive.extractTo(repo.packagesDir.subdirectory([pkg.organization, pkg.name, "${pkg.version}"]));
    temp.deleteSync(recursive: true);
  }
}

