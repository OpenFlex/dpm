// Copyright (c) 2011, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class PackageException extends DpmException {
  PackageException(String message) : super(message);
}

class PackageCoordinates {
  static final RegExp _id = const RegExp(@'^[a-zA-Z0-9_][a-zA-Z0-9\-\.]*$');

  final String organization;
  final String name;
  final VersionSpecification version;

  PackageCoordinates(String this.organization, String this.name, VersionSpecification this.version);

  factory PackageCoordinates.parse(String pkg) {
    final parts = pkg.split(':');
    if (parts.length != 3) {
      throw new PackageException("Package coordinates '$pkg' has bad format (it must have 3 parts)");
    }

    String organization = parts[0];
    String name = parts[1];
    VersionSpecification version = new VersionSpecification(parts[2]);

    if (!_id.hasMatch(organization)) {
      throw new PackageException("Package organization is malformed in '$pkg'");
    }
    if (!_id.hasMatch(name)) {
      throw new PackageException("Package name is malformed in '$pkg'");
    }

    return new PackageCoordinates(organization, name, version);
  }

  bool operator==(other) => other is PackageCoordinates
      && organization == other.organization
      && name == other.name
      && version == other.version;

  String toString() => '$organization:$name:$version';
}

class _PackageDescriptor {
  Map<String, String> content;

  _PackageDescriptor(Map<String, String> this.content);

  factory _PackageDescriptor.parse(String descriptor) {
    Map<String, String> content = new Map<String, String>();
    List<String> lines = descriptor.split("\n");
    for (String line in lines) {
      if (line.trim().length == 0) {
        continue;
      }

      int delimiterIdx = line.indexOf(":", 0);
      if (delimiterIdx == -1) {
        throw new PackageException("Line in descriptor '$line' has bad format");
      }
      String key = line.substring(0, delimiterIdx).trim();
      String value = line.substring(delimiterIdx + 1).trim();
      content[key.toLowerCase()] = value;
    }
    return new _PackageDescriptor(content);
  }

  String mandatory(String variable) {
    String value = content[variable.toLowerCase()];
    if (value == null) {
      throw new PackageException("Variable '$variable' is mandatory in package descriptor");
    }
    return value;
  }

  String optional(String variable, [String defaultValue = null]) {
    String value = content[variable.toLowerCase()];
    return value != null ? value : defaultValue;
  }
}

class Package {
  final String organization;
  final String name;
  final Version version;
  final String mainScript;
  final List<PackageCoordinates> dependencies;
  final String author;
  final String license;
  final String description;

  Package._new(String this.organization, String this.name, Version this.version,
               String this.mainScript, List<PackageCoordinates> this.dependencies,
               String this.author, String this.license, String this.description);

  factory Package.fromDescriptor(String descriptorStr) {
    _PackageDescriptor descriptor = new _PackageDescriptor.parse(descriptorStr);

    String organization = descriptor.mandatory("Organization");
    String name = descriptor.mandatory("Name");;
    String versionStr = descriptor.mandatory("Version");
    String mainScript = descriptor.optional("Main-Script");
    String dependenciesStr = descriptor.optional("Dependencies", "");
    String author = descriptor.optional("Author");
    String license = descriptor.optional("License");
    String description = descriptor.optional("Description");

    List<PackageCoordinates> dependencies = new List<PackageCoordinates>();
    List<String> dependenciesParts = dependenciesStr.split(",");
    for (String dependencyStr in dependenciesParts) {
      if (dependencyStr.trim().length == 0) {
        continue;
      }

      dependencies.add(new PackageCoordinates.parse(dependencyStr));
    }

    Version version = new Version(versionStr);

    return new Package._new(organization, name, version, mainScript, dependencies, author, license, description);
  }

  factory Package.fromDescriptorFile(File descriptorFile) {
    FileInputStream input = descriptorFile.openInputStream();
    StringInputStream strInput = new StringInputStream(input, "UTF-8");
    String descriptor = strInput.readSync();
    input.close();
    return new Package.fromDescriptor(descriptor);
  }

  String toString() => 'package $organization:$name:$version';
}

