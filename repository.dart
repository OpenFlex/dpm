// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class RepositoryException extends DpmException {
  RepositoryException(String message) : super(message);
}

interface Repository {
  List<Version> findAvailableVersions(String organization, String name);
  Package readPackage(String organization, String name, Version version);
  String toUrl(Package package, [String script]);
}

class FilesystemRepository implements Repository {
  final Directory root;

  FilesystemRepository(Directory dpmRoot) : root = dpmRoot.subdirectory(['packages']);

  List<Version> findAvailableVersions(String organization, String name) {
    List<Version> result = new List<Version>();

    Directory packageDir = root.subdirectory([organization, name]);
    if (!packageDir.existsSync()) {
      return result;
    }

    packageDir.dirHandler = (String dir) => result.add(new Version(dir));

    packageDir.listSync(fullPaths: false);

    return result;
  }

  Package readPackage(String organization, String name, Version version) {
    Directory packageDir = root.subdirectory([organization, name, "$version"]);
    if (!packageDir.existsSync()) {
      throw new RepositoryException("Package '$organization:$name:$version' doesn't exist in '${root.path}'");
    }

    File packageDescriptorFile = packageDir.file("info.dpm");
    if (!packageDescriptorFile.existsSync()) {
      throw new RepositoryException("Package '$organization:$name:$version' in '${root.path}' doesn't contain a descriptor (info.dpm)");
    }

    return new Package.fromDescriptorFile(packageDescriptorFile);
  }

  String toUrl(Package package, [String script = null]) {
    Directory packageDir = root.subdirectory([package.organization, package.name, "${package.version}"]);
    if (script != null) {
      return packageDir.file(script).name;
    } else if (package.mainScript != null) {
      return packageDir.file(package.mainScript).name;
    } else {
      throw new RepositoryException("$package doesn't specify Main-Script and no script was defined");
    }
  }
}

class _LocalUserRepository extends FilesystemRepository {
  _LocalUserRepository() : super(new Directory.home().subdirectory([".dpm"]));
}

