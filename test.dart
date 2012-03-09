#import('dart:io');
#import("dpm.dart");
#import("../dart-matchers/matchers.dart");
#import("../dart-matchers/io/io-matchers.dart");

var testrepo = 'not yet determined';

determineTestRepoPath() {
  var script = new Options().script;
  var testrepoDir = new File(script).directorySync().subdirectory(["testfiles", "repo"]);
  testrepo = testrepoDir.path;
}

Repository buildTestRepo() {
  Directory repoDir = new Directory(testrepo);
  expectThat(repoDir, directoryExists());

  return new FilesystemRepository(repoDir);
}

testVersions() {
  Version v = new Version("1.0");

  VersionSpecification s = new VersionSpecification("1.0");
  expectThat(s.isSatisfiedBy(v), isTrue());
  expectThat("$s", equals("1.0"));

  s = new VersionSpecification("0.1");
  expectThat(s.isSatisfiedBy(v), isFalse());
  expectThat("$s", equals("0.1"));

  s = new VersionSpecification("1.1");
  expectThat(s.isSatisfiedBy(v), isFalse());
  expectThat("$s", equals("1.1"));

  s = new VersionSpecification("2.0");
  expectThat(s.isSatisfiedBy(v), isFalse());
  expectThat("$s", equals("2.0"));

  s = new VersionSpecification("1.*");
  expectThat(s.isSatisfiedBy(v), isTrue());
  expectThat("$s", equals("1.*"));

  s = new VersionSpecification("*");
  expectThat(s.isSatisfiedBy(v), isTrue());
  expectThat("$s", equals("*"));

  s = new VersionSpecification("0.*");
  expectThat(s.isSatisfiedBy(v), isFalse());
  expectThat("$s", equals("0.*"));

  s = new VersionSpecification("2.*");
  expectThat(s.isSatisfiedBy(v), isFalse());
  expectThat("$s", equals("2.*"));

  expectThat( () => new Version(null), throwsException());
  expectThat( () => new Version("a"), throwsException());
  expectThat( () => new Version("1.*"), throwsException());
  expectThat( () => new VersionSpecification(null), throwsException());
  expectThat( () => new VersionSpecification("a"), throwsException());
  expectThat( () => new VersionSpecification("1*"), throwsException());
}

testPackages() {
  expectThat( () => new PackageId("org", "name", new Version("0.1")), returnsNormally());
  expectThat( () => new PackageId("-org", "name", new Version("0.1")), throwsException());
  expectThat( () => new PackageId("org", "-name", new Version("0.1")), throwsException());
  expectThat( () => new PackageId("org", "name", new Version("-0.1")), throwsException());
  expectThat( () => new PackageId("org", "name", null), throwsException());
  expectThat( () => new PackageId("org", null, new Version("0.1")), throwsException());
  expectThat( () => new PackageId(null, "name", new Version("0.1")), throwsException());

  expectThat( () => new PackageId("_org", "0name", new Version("0.1")), returnsNormally());
  expectThat( () => new PackageId("_o1r-g.", "0n_a-m.e1", new Version("0.1")), returnsNormally());

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

  p = new PackageCoordinates.parse("dart-matchers:0.1");
  expectThat(p.organization, isNull());
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, equals(new VersionSpecification("0.1")));

  p = new PackageCoordinates.parse("dart-matchers:0.*");
  expectThat(p.organization, isNull());
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, equals(new VersionSpecification("0.*")));

  p = new PackageCoordinates.parse("com.ladicek:dart-matchers");
  expectThat(p.organization, equals("com.ladicek"));
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, isNull());

  p = new PackageCoordinates.parse("dart-matchers");
  expectThat(p.organization, isNull());
  expectThat(p.name, equals("dart-matchers"));
  expectThat(p.version, isNull());

  p = new PackageCoordinates.parse("0.1");
  expectThat(p.organization, isNull());
  expectThat(p.name, equals("0.1"));
  expectThat(p.version, isNull());

  expectThat( () => new PackageCoordinates.parse(null), throwsException());
  expectThat( () => new PackageCoordinates.parse(""), throwsException());
  expectThat( () => new PackageCoordinates.parse("-"), throwsException());
  expectThat( () => new PackageCoordinates.parse("--"), throwsException());
}

testFilesystemRepository() {
  Repository repo = buildTestRepo();

  List<PackageId> pkgs = repo.find(new PackageCoordinates.parse("doesnt:exist"));
  expectThat(pkgs, emptyCollection());

  pkgs = repo.find(new PackageCoordinates.parse("com.ladicek:doesnt-exist"));
  expectThat(pkgs, emptyCollection());

  pkgs = repo.find(new PackageCoordinates.parse("doesnt-exist"));
  expectThat(pkgs, emptyCollection());

  pkgs = repo.find(new PackageCoordinates.parse("com.ladicek:dart-matchers:0.3"));
  expectThat(pkgs, emptyCollection());

  pkgs = repo.find(new PackageCoordinates.parse("dart-matchers:0.3"));
  expectThat(pkgs, emptyCollection());

  pkgs = repo.find(new PackageCoordinates.parse("com.ladicek:dart-matchers"));
  expectThat(pkgs, unorderedEquals([
      new PackageId("com.ladicek", "dart-matchers", new Version("0.1")),
      new PackageId("com.ladicek", "dart-matchers", new Version("0.2"))
  ]));

  pkgs = repo.find(new PackageCoordinates.parse("dart-matchers"));
  expectThat(pkgs, unorderedEquals([
      new PackageId("com.ladicek", "dart-matchers", new Version("0.1")),
      new PackageId("com.ladicek", "dart-matchers", new Version("0.2")),
      new PackageId("com.example", "dart-matchers", new Version("0.0.1"))
  ]));

  pkgs = repo.find(new PackageCoordinates.parse("dart-matchers:0.*"));
  expectThat(pkgs, unorderedEquals([
      new PackageId("com.ladicek", "dart-matchers", new Version("0.1")),
      new PackageId("com.ladicek", "dart-matchers", new Version("0.2")),
      new PackageId("com.example", "dart-matchers", new Version("0.0.1"))
  ]));

  pkgs = repo.find(new PackageCoordinates.parse("dart-matchers:0.1"));
  expectThat(pkgs, unorderedEquals([
      new PackageId("com.ladicek", "dart-matchers", new Version("0.1"))
  ]));

  PackageId pkgId = new PackageId("com.ladicek", "dart-matchers", new Version("0.1"));
  Package pkg = repo.readPackage(pkgId);
  expectThat(pkg.id, equals(pkgId));
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

  pkgId = new PackageId("com.example", "dart-matchers", new Version("0.0.1"));
  pkg = repo.readPackage(pkgId);
  expectThat(pkg.id, equals(pkgId));
  expectThat(pkg.organization, equals("com.example"));
  expectThat(pkg.name, equals("dart-matchers"));
  expectThat(pkg.version, equals(new Version("0.0.1")));
  expectThat(pkg.mainScript, isNull());
  expectThat(pkg.author, isNull());
  expectThat(pkg.license, isNull());
  expectThat(pkg.description, equals("An artificial package with intentionally duplicate name"));
  expectThat(pkg.dependencies, emptyCollection());
  expectThat(pkg.binaries, orderedEquals(["test-matchers", "run-matcher"]));

  expectThat( () => repo.toUrl(pkg), throwsException());

  url = repo.toUrl(pkg, "main.dart");
  expectThat(url, equals("$testrepo/packages/com.example/dart-matchers/0.0.1/main.dart"));
}

testImportSpecification() {
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

  i = new ImportSpecification.parse("com.ladicek:dart-matchers");
  expectThat(i.organization, equals("com.ladicek"));
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, isNull());
  expectThat(i.script, isNull());

  i = new ImportSpecification.parse("dart-matchers");
  expectThat(i.organization, isNull());
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, isNull());
  expectThat(i.script, isNull());

  i = new ImportSpecification.parse("dart-matchers:0.1");
  expectThat(i.organization, isNull());
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("0.1")));
  expectThat(i.script, isNull());

  i = new ImportSpecification.parse("com.ladicek:dart-matchers/matchers.dart");
  expectThat(i.organization, equals("com.ladicek"));
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, isNull());
  expectThat(i.script, equals("matchers.dart"));

  i = new ImportSpecification.parse("dart-matchers/src/matchers.dart");
  expectThat(i.organization, isNull());
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, isNull());
  expectThat(i.script, equals("src/matchers.dart"));

  i = new ImportSpecification.parse("dart-matchers:0.1/matchers.dart");
  expectThat(i.organization, isNull());
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("0.1")));
  expectThat(i.script, equals("matchers.dart"));

  i = new ImportSpecification.parse("dart-matchers:0.*/src/matchers.dart");
  expectThat(i.organization, isNull());
  expectThat(i.name, equals("dart-matchers"));
  expectThat(i.version, equals(new VersionSpecification("0.*")));
  expectThat(i.script, equals("src/matchers.dart"));
}

testImportResolving() {
  Repository repo = buildTestRepo();

  ImportSpecification spec = new ImportSpecification.parse("doesnt:exist:0");
  expectThat( () => new Import.resolve(spec, repo), throwsException());

  spec = new ImportSpecification.parse("doesnt-exist:0");
  expectThat( () => new Import.resolve(spec, repo), throwsException());

  spec = new ImportSpecification.parse("doesnt-exist");
  expectThat( () => new Import.resolve(spec, repo), throwsException());

  spec = new ImportSpecification.parse("dart-matchers");
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

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.2/matchers.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-matchers/matchers.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-matchers/0.2/matchers.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:0.1");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/0.1/query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:0.*");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/0.2/query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:*");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/query.dart"));

  spec = new ImportSpecification.parse("dart-query");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:0.1/dart-query.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/0.1/dart-query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:0.*/dart-query.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/0.2/dart-query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query:*/dart-query.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/dart-query.dart"));

  spec = new ImportSpecification.parse("com.ladicek:dart-query/dart-query.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/dart-query.dart"));

  spec = new ImportSpecification.parse("dart-query/dart-query.dart");
  resolved = new Import.resolve(spec, repo);
  expectThat(resolved.url, equals("$testrepo/packages/com.ladicek/dart-query/1.0/dart-query.dart"));
}

main() {
  determineTestRepoPath();

  testVersions();
  testPackages();
  testFilesystemRepository();
  testImportSpecification();
  testImportResolving();

  print("ok");
}

