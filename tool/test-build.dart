#import('dart:io');
#import('dpm-tool.dart');
#import('../../dart-matchers/matchers.dart');
#import('../../dart-matchers/io/io-matchers.dart');

main() {
  var script = new Options().script;
  var testFiles = new File(script).directorySync().subdirectory(["testfiles", "build"]);
  var testFilesPath = testFiles.path;
  expectThat(testFiles, directoryExists());

  expectThat( () => build([]), throwsException());

  expectThat( () => build(["$testFilesPath/my-lib", "ignored"]), throwsException());
  expectThat( () => build(["$testFilesPath/my-lib", "-ignored", "ignored"]), throwsException());
  expectThat( () => build(["$testFilesPath/my-lib", "+ignored", "ignored"]), throwsException());

  expectThat( () => build(["$testFilesPath/nonexisting-directory"]), throwsException());
  expectThat( () => build(["$testFilesPath/no-descriptor"]), throwsException());

  expectThat( () => build(["$testFilesPath/my-lib"]), returnsNormally());
  var package = new File("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  var archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "ignored.txt",
        "info.dpm",
        "lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  expectThat( () => build(["$testFilesPath/my-lib-with-subdir"]), returnsNormally());
  package = new File("my-organization-my-lib-0.1.arraz");
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

  expectThat( () => build(["$testFilesPath/my-lib", "+info.dpm", "+lib.dart"]), returnsNormally());
  package = new File("my-organization-my-lib-0.1.arraz");
  expectThat(package, fileExists());
  archive = new ExtractArchive(package);
  expectThat(archive.listEntries(), unorderedEquals([
        "info.dpm",
        "lib.dart"
  ]));
  package.deleteSync();
  expectThat(package, not(fileExists()));

  expectThat( () => build(["$testFilesPath/my-lib-with-ignored-subdir", "-ignored"]), returnsNormally());
  package = new File("my-organization-my-lib-0.1.arraz");
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

