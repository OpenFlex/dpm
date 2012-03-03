#import('dart:io');
#import('dpm-tool.dart');
#import('../../dart-matchers/matchers.dart');
#import('../../dart-matchers/io/io-matchers.dart');

main() {
  var script = new Options().script;
  var testFiles = new File(script).directorySync().subdirectory(["testfiles", "build"]);
  var testFilesPath = testFiles.path;
  expectThat(testFiles, directoryExists());

  expectThat( () => build([], testFiles), throwsException());

  expectThat( () => build(["$testFilesPath/my-lib", "ignored"], testFiles), throwsException());
  expectThat( () => build(["$testFilesPath/my-lib", "-ignored", "ignored"], testFiles), throwsException());
  expectThat( () => build(["$testFilesPath/my-lib", "+ignored", "ignored"], testFiles), throwsException());

  expectThat( () => build(["$testFilesPath/nonexisting-directory"], testFiles), throwsException());
  expectThat( () => build(["$testFilesPath/no-descriptor"], testFiles), throwsException());
  expectThat( () => build(["$testFilesPath/invalid-descriptor"], testFiles), throwsException());

  expectThat( () => build(["$testFilesPath/my-lib"], testFiles), returnsNormally());
  var package = testFiles.file("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  var archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "ignored.txt",
        "info.dpm",
        "lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  expectThat( () => build(["$testFilesPath/my-lib-with-subdir"], testFiles), returnsNormally());
  package = testFiles.file("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "ignored.txt",
        "info.dpm",
        "lib.dart",
        "special-lib/special-lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  expectThat( () => build(["$testFilesPath/my-lib", "+info.dpm", "+lib.dart"], testFiles), returnsNormally());
  package = testFiles.file("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "info.dpm",
        "lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  expectThat( () => build(["$testFilesPath/my-lib-with-ignored-subdir", "-ignored"], testFiles), returnsNormally());
  package = testFiles.file("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "info.dpm",
        "lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  print("ok");
}

