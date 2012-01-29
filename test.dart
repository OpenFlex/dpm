#import('dart:io');
#import("dpm.dart");
#import("../dart-matchers/matchers.dart");

final String testrepo = "/home/ladicek/work/dart-package-manager/testrepo";

testVersions() {
  Version v = new Version("1.0");

  VersionSpecification s = new VersionSpecification("1.0");
  expectThat(s.isSatisfiedBy(v), isTrue());

  s = new VersionSpecification("0.1");
  expectThat(s.isSatisfiedBy(v), isFalse());

  s = new VersionSpecification("1.1");
  expectThat(s.isSatisfiedBy(v), isFalse());

  s = new VersionSpecification("2.0");
  expectThat(s.isSatisfiedBy(v), isFalse());

  s = new VersionSpecification("1.*");
  expectThat(s.isSatisfiedBy(v), isTrue());

  s = new VersionSpecification("*");
  expectThat(s.isSatisfiedBy(v), isTrue());

  s = new VersionSpecification("0.*");
  expectThat(s.isSatisfiedBy(v), isFalse());

  s = new VersionSpecification("2.*");
  expectThat(s.isSatisfiedBy(v), isFalse());

  expectThat( () => new Version("a"), throwsException());
  expectThat( () => new Version("1.*"), throwsException());
  expectThat( () => new VersionSpecification("a"), throwsException());
  expectThat( () => new VersionSpecification("1*"), throwsException());
}

testPackages() {
  String descriptor = """
Organization: com.ladicek
Name: dart-matchers
Version: 0.1
Main-Script: matchers.dart
Author: Ladislav Thon
License: BSD
Description: A small library of matchers in Dart
""";

  Package pkg = new Package.fromDescriptor(descriptor);
  expectThat(pkg.organization, equals("com.ladicek"));
  expectThat(pkg.name, equals("dart-matchers"));
  expectThat(pkg.version, equals(new Version("0.1")));
  expectThat(pkg.mainScript, equals("matchers.dart"));
  expectThat(pkg.author, equals("Ladislav Thon"));
  expectThat(pkg.license, equals("BSD"));
  expectThat(pkg.description, equals("A small library of matchers in Dart"));
  expectThat(pkg.dependencies, emptyCollection());
  expectThat(pkg.binaries, emptyCollection());

  descriptor = """
Organization: com.ladicek
Name: dart-query
Version: 0.1
Main-Script: query.dart
Dependencies: com.ladicek:dart-matchers:0.1
Author: Ladislav Thon
License: BSD
Description: A small library for working with collections in Dart
""";

  pkg = new Package.fromDescriptor(descriptor);
  expectThat(pkg.organization, equals("com.ladicek"));
  expectThat(pkg.name, equals("dart-query"));
  expectThat(pkg.version, equals(new Version("0.1")));
  expectThat(pkg.mainScript, equals("query.dart"));
  expectThat(pkg.author, equals("Ladislav Thon"));
  expectThat(pkg.license, equals("BSD"));
  expectThat(pkg.description, equals("A small library for working with collections in Dart"));
  PackageCoordinates dep = new PackageCoordinates.parse("com.ladicek:dart-matchers:0.1");
  expectThat(pkg.dependencies, orderedEquals([dep]));
  expectThat(pkg.binaries, emptyCollection());

  descriptor = """
Organization: com.ladicek
Name: test-program
Version: 0.1
Main-Script: program.dart
Binaries: program, runner
""";

  pkg = new Package.fromDescriptor(descriptor);
  expectThat(pkg.organization, equals("com.ladicek"));
  expectThat(pkg.name, equals("test-program"));
  expectThat(pkg.version, equals(new Version("0.1")));
  expectThat(pkg.mainScript, equals("program.dart"));
  expectThat(pkg.author, isNull());
  expectThat(pkg.license, isNull());
  expectThat(pkg.description, isNull());
  expectThat(pkg.dependencies, emptyCollection());
  expectThat(pkg.binaries, orderedEquals(["program", "runner"]));

  PackageCoordinates p = new PackageCoordinates.parse("com.ladicek:dart-matchers:0.1");
  expectThat(p.organization, equals("com.ladicek"));
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, equals(new VersionSpecification("0.1")));

  p = new PackageCoordinates.parse("com.ladicek:dart-matchers:0.*");
  expectThat(p.organization, equals("com.ladicek"));
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, equals(new VersionSpecification("0.*")));
}

Repository _buildTestRepo() {
  Directory repoDir = new Directory(testrepo);
  expectThat(repoDir.existsSync(), isTrue());

  return new FilesystemRepository(repoDir);
}

testFilesystemRepository() {
  Repository repo = _buildTestRepo();

  List<Version> v = repo.findAvailableVersions("doesnt", "exist");
  expectThat(v, emptyCollection());

  v = repo.findAvailableVersions("com.ladicek", "dart-matchers");
  expectThat(v.length, equals(2));
  expectThat(v, collectionContains(new Version("0.1")));
  expectThat(v, collectionContains(new Version("0.2")));

  Package pkg = repo.readPackage("com.ladicek", "dart-matchers", new Version("0.1"));
  expectThat(pkg.organization, equals("com.ladicek"));
  expectThat(pkg.name, equals("dart-matchers"));
  expectThat(pkg.version, equals(new Version("0.1")));
  expectThat(pkg.mainScript, equals("matchers.dart"));
  expectThat(pkg.author, equals("Ladislav Thon"));
  expectThat(pkg.license, equals("BSD"));
  expectThat(pkg.description, equals("A small library of matchers in Dart"));
  expectThat(pkg.dependencies, emptyCollection());
  expectThat(pkg.binaries, emptyCollection());

  String url = repo.toUrl(pkg);
  expectThat(url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.1/matchers.dart"));
}

testImports() {
  ImportSpecification i = new ImportSpecification.parse("com.ladicek:dart-matchers:0.1");
  expectThat(i.organization, equals("com.ladicek"));
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("0.1")));
  expectThat(i.script, isNull());

  i = new ImportSpecification.parse("com.ladicek:dart-matchers:0.*/matchers.dart");
  expectThat(i.organization, equals("com.ladicek"));
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("0.*")));
  expectThat(i.script, equals("matchers.dart"));

  i = new ImportSpecification.parse("com.ladicek:dart-matchers:*/src/matchers.dart");
  expectThat(i.organization, equals("com.ladicek"));
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("*")));
  expectThat(i.script, equals("src/matchers.dart"));

  Repository repo = _buildTestRepo();

  ImportSpecification spec = new ImportSpecification.parse("doesnt:exist:0");
  expectThat( () => new Import.resolve(spec, repo), throwsException());

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers:0.1");
  Import resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.1/matchers.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers:0.*");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.2/matchers.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers:0.*/dart-matchers.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.2/dart-matchers.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers:0.1/src/dart-matchers.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.1/src/dart-matchers.dart"));
}

main() {
  testVersions();
  testPackages();
  testFilesystemRepository();
  testImports();

  print("ok");
}

