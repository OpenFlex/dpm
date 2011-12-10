// Copyright (c) 2011, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class ResolvingException extends DpmException {
  ResolvingException(String message) : super(message);
}

class ImportSpecification {
  final PackageCoordinates coordinates;
  final String script;

  ImportSpecification._new(PackageCoordinates this.coordinates, String this.script);

  factory ImportSpecification.parse(String import) {
    String coordinatesStr = import;
    String script;
    final scriptIdx = import.indexOf('/', 0);
    if (scriptIdx != -1) {
      coordinatesStr = import.substring(0, scriptIdx);
      script = import.substring(scriptIdx + 1, import.length);
    }

    PackageCoordinates coordinates = new PackageCoordinates.parse(coordinatesStr);

    return new ImportSpecification._new(coordinates, script);
  }

  String get organization() => coordinates.organization;
  String get name() => coordinates.name;
  VersionSpecification get version() => coordinates.version;

  String toString() => script != null ? '$organization:$name:$version/$script' : '$organization:$name:$version';
}

class Import {
  final String url;

  Import._new(String this.url);

  factory Import.resolve(ImportSpecification spec, Repository repo) {
    List<Version> availableVersions = repo.findAvailableVersions(spec.organization, spec.name);
    List<Version> candidates = availableVersions.filter( (v) => spec.version.isSatisfiedBy(v) );

    if (candidates.length == 0) {
      throw new ResolvingException("Couldn't resolve '$spec'");
    }

    candidates.sort( (a, b) => -1 * a.compareTo(b) ); // highest first

    Version selectedVersion = candidates[0];
    Package package = repo.readPackage(spec.organization, spec.name, selectedVersion);

    String url = repo.toUrl(package, spec.script);
    return new Import._new(url);
  }
}

