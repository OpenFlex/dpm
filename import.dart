// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
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

  String toString() => script != null ? '$coordinates/$script' : '$coordinates';
}

class Import implements Hashable {
  final Package package;
  final String url;

  Import._new(Package this.package, String this.url);

  bool operator ==(other) => other is Import && url == other.url;

  int hashCode() => url.hashCode();

  String toString() => 'imported $package';
}

interface ImportResolver {
  Import resolve(ImportSpecification spec);
}

/// The basic import resolving algorithm. Always resolves to the highest
/// version of all candidates satisfying the specification. Throws an exception
/// when no candidate is found or when organization is not specified and there
/// are packages with the same name from different organizations.
class BasicImportResolver implements ImportResolver {
  final Repository repo;

  BasicImportResolver(Repository this.repo);

  Import resolve(ImportSpecification spec) {
    List<PackageId> candidates = repo.find(spec.coordinates);

    if (candidates.length == 0) {
      throw new ResolvingException("Couldn't resolve '$spec'");
    }

    if (spec.organization == null) {
      Set<String> organizations = new Set<String>();
      for (PackageId candidate in candidates) {
        organizations.add(candidate.organization);
      }
      if (organizations.length > 1) {
        String organizationsDesc = Strings.join(new List.from(organizations), ', ');
        throw new ResolvingException("Package '${spec.name}' is available from more organizations [$organizationsDesc], the organization must be specified explicitly");
      }
    }

    candidates.sort( (a, b) => -a.version.compareTo(b.version) ); // highest first

    PackageId selected = candidates[0];
    Package package = repo.readPackage(selected);

    String url = repo.toUrl(package, spec.script);
    return new Import._new(package, url);
  }
}

/// Builds on top of the [BasicImportResolver] and prevents resolving more
/// than one version of a single package. If one version of a package
/// (organization:name:version) was already resolved and another version
/// of the same package (organization:name:differentVersion) is to be resolved
/// now, throws an exception.
class RuntimeAwareImportResolver implements ImportResolver {
  final BasicImportResolver basicResolver;
  final Map<String, Version> alreadyResolved;

  RuntimeAwareImportResolver(Repository repo)
    : basicResolver = new BasicImportResolver(repo), alreadyResolved = <Version>{};

  Import resolve(ImportSpecification spec) {
    Import import = basicResolver.resolve(spec);

    String key = "${import.package.organization}:${import.package.name}";
    if (alreadyResolved.containsKey(key) && import.package.version != alreadyResolved[key]) {
      throw new ResolvingException("Tried to import package '${import.package}', but '$key' was already imported (version '${alreadyResolved[key]}')");
    }

    alreadyResolved[key] = import.package.version;
    return import;
  }
}

