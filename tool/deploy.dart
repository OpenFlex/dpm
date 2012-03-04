// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

deploy(List<String> args, [FilesystemRepository repo]) {
  if (args == null || args.length == 0) {
    throw new ToolException("The 'deploy' command needs at least one argument");
  }

  if (repo == null) {
    repo = new LocalUserRepository();
  }

  Directory temp = new Directory(repo.root.path).subdirectory(["temp"]);
  try {
    temp.createTempSync();

    // check first -- all packages must exist and have a valid descriptor
    for (String pkgPath in args) {
      var pkg = new File(pkgPath);
      if (!pkg.existsSync()) {
        throw new ToolException("The package '$pkgPath' doesn't exist");
      }

      var pkgArchive = new ExtractArchive(pkg);
      if (!pkgArchive.findEntry("info.dpm")) {
        throw new ToolException("The package '$pkgPath' doesn't containt the 'info.dpm' descriptor");
      }

      pkgArchive.extractEntry("info.dpm", temp);
      var descriptorFile = temp.file("info.dpm");

      try {
        new Package.fromDescriptorFile(descriptorFile);
      } catch (PackageException e) {
        throw new ToolException("Package '$pkgPath' has bad descriptor (${e.message})");
      } finally {
        descriptorFile.deleteSync();
      }
    }

    for (String pkgPath in args) {
      var pkgArchive = new ExtractArchive(new File(pkgPath));

      try {
        pkgArchive.extractEntry("info.dpm", temp);

        Package pkg = new Package.fromDescriptorFile(temp.file("info.dpm"));
        pkgArchive.extractTo(repo.packagesDir.subdirectory([pkg.organization, pkg.name, "${pkg.version}"]));
      } finally {
        temp.deleteRecursivelySync();
      }
    }
  } finally {
    temp.deleteRecursivelySync();
  }
}

