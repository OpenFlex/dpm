#import('dart:io');
#import('dpm-tool.dart');
#import('../../dart-matchers/matchers.dart');
#import('../../dart-matchers/io/io-matchers.dart');
#import('../../dartlings/files.dart');

final expectedOneLibNoImports = """
Organization: my-organization
Name: my-lib
Version: 0.1
Main-Script: lib.dart

""";

final expectedOneLibWithImports = """
Organization: my-organization
Name: my-lib-with-dependencies
Version: 0.1
Main-Script: lib.dart
Dependencies: my:dependency1:1.0, dependency2:1.0, dependency3, my:dependency4

""";

main() {
  var scriptPath = new Options().script;
  var testFilesRoot = scriptPath.replaceFirst("test-infer.dart", "testfiles/infer");
  expectThat(new Directory(testFilesRoot), directoryExists());

  expectThat( () => infer([]), throwsException());
  expectThat( () => infer(["one", "two"]), throwsException());

  expectThat( () => infer(["$testFilesRoot/nonexisting-directory"]), throwsException());
  expectThat( () => infer(["$testFilesRoot/no-dart-file"]), throwsException());
  expectThat( () => infer(["$testFilesRoot/no-lib"]), throwsException());
  expectThat( () => infer(["$testFilesRoot/more-libs"]), throwsException());

  expectThat( () => infer(["$testFilesRoot/one-lib-no-imports"]), returnsNormally());
  var infoDpm = new File("$testFilesRoot/one-lib-no-imports/info.dpm");
  expectThat(infoDpm, fileExists());
  expectThat(infoDpm, fileContent(equals(expectedOneLibNoImports)));
  infoDpm.deleteSync();
  expectThat(infoDpm, not(fileExists()));

  expectThat( () => infer(["$testFilesRoot/one-lib-with-imports"]), returnsNormally());
  infoDpm = new File("$testFilesRoot/one-lib-with-imports/info.dpm");
  expectThat(infoDpm, fileExists());
  expectThat(infoDpm, fileContent(equals(expectedOneLibWithImports)));
  infoDpm.deleteSync();
  expectThat(infoDpm, not(fileExists()));

  print("ok");
}

