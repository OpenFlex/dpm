#import('dart:io');
#import('../dpm.dart');
#import('dpm-tool.dart');
#import('../../dart-matchers/matchers.dart');
#import('../../dart-matchers/io/io-matchers.dart');

main() {
  var script = new Options().script;
  var testFiles = new File(script).directorySync().subdirectory(["testfiles", "deploy"]);
  var testFilesPath = testFiles.path;
  expectThat(testFiles, directoryExists());

  var buildTestFiles = new File(script).directorySync().subdirectory(["testfiles", "build"]);
  var buildTestFilesPath = buildTestFiles.path;
  expectThat(buildTestFiles, directoryExists());

  var repo = new FilesystemRepository(testFiles.subdirectory(["repo"]));

  expectThat( () => deploy([], repo), throwsException());

  expectThat( () => deploy(["$testFilesPath/nonexisting-archive.arraz"], repo), throwsException());
  expectThat( () => deploy(["$testFilesPath/empty-archive.arraz"], repo), throwsException());
  expectThat( () => deploy(["$testFilesPath/package-without-descriptor.arraz"], repo), throwsException());
  expectThat( () => deploy(["$testFilesPath/package-with-invalid-descriptor.arraz"], repo), throwsException());

  expectThat( () => build(["$buildTestFilesPath/my-lib"], testFiles), returnsNormally());
  var package = testFiles.file("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());

  expectThat( () => deploy([package.fullPathSync()], repo), returnsNormally());
  var pkgDir = testFiles.subdirectory(["repo", "packages", "my-organization", "my-lib", "0.1"]);
  expectThat(pkgDir, directoryExists());
  expectThat(pkgDir.file("info.dpm"), fileExists());
  expectThat(pkgDir.file("lib.dart"), fileExists());
  expectThat(pkgDir.file("ignored.txt"), fileExists());

  package.deleteSync();
  expectThat(package, not(fileExists()));

  var pkgsDir = testFiles.subdirectory(["repo", "packages"]);
  pkgsDir.deleteRecursivelySync();
  expectThat(pkgsDir, not(directoryExists()));

  print("ok");
}

