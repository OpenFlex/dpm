// Copyright (c) 2011, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class VersionException extends DpmException {
  VersionException(String message) : super(message);
}

class Version implements Comparable {
  static final RegExp _versionFormat = const RegExp(@'^([0-9]+\.)?[0-9]+$');

  final String _value;

  Version(String this._value) {
    if (!_versionFormat.hasMatch(_value)) {
      throw new VersionException("Version '$_value' has bad format");
    }
  }

  bool operator==(Object other) => other is Version && _value == other._value;

  int compareTo(Version other) => _value.compareTo(other._value);

  String toString() => _value;
}

interface VersionSpecification factory _VersionSpecificationParser {
  VersionSpecification(String version);

  bool isSatisfiedBy(Version version);

  bool operator==(VersionSpecification other);

  String toString();
}

class _FixedVersionSpecification implements VersionSpecification {
  final String value;

  _FixedVersionSpecification(String this.value);

  bool isSatisfiedBy(Version version) => value == version._value;

  bool operator==(other) => other is _FixedVersionSpecification && value == other.value;

  String toString() => value;
}

class _WildcardVersionSpecification implements VersionSpecification {
  final String value;

  _WildcardVersionSpecification(String this.value);

  bool isSatisfiedBy(Version version) => version._value.startsWith(value);

  bool operator==(other) => other is _WildcardVersionSpecification && value == other.value;

  String toString() => value;
}

class _VersionSpecificationParser {
  static final RegExp fixedVersion = Version._versionFormat;
  static final RegExp wildcardVersion = const RegExp(@'^([0-9]+\.)*\*$');

  factory VersionSpecification(String version) {
    if (fixedVersion.hasMatch(version)) {
      return new _FixedVersionSpecification(version);
    } else if (wildcardVersion.hasMatch(version)) {
      if (version.endsWith('*')) { version = version.substring(0, version.length - 1); }
      if (version.endsWith('.')) { version = version.substring(0, version.length - 1); }
      return new _WildcardVersionSpecification(version);
    } else {
      throw new VersionException("Version specification '$version' has bad format");
    }
  }
}

