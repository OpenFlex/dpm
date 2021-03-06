#import('dart:io');
#import('dpm-tool.dart');
#import('../../dart-matchers/matchers.dart');
#import('../../dart-matchers/io/io-matchers.dart');

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
  var script = new Options().script;
  var testFiles = new File(script).directorySync().subdirectory(["testfiles", "infer"]);
  var testFilesPath = testFiles.path;
  expectThat(testFiles, directoryExists());

  expectThat( () => infer(null), throws());
  expectThat( () => infer([]), throws());
  expectThat( () => infer(["one", "two"]), throws());

  expectThat( () => infer(["$testFilesPath/nonexisting-directory"]), throws());
  expectThat( () => infer(["$testFilesPath/no-dart-file"]), throws());
  expectThat( () => infer(["$testFilesPath/no-lib"]), throws());
  expectThat( () => infer(["$testFilesPath/more-libs"]), throws());

  expectThat( () => infer(["$testFilesPath/one-lib-no-imports"]), returnsNormally());
  var infoDpm = new File("$testFilesPath/one-lib-no-imports/info.dpm");
  expectThat(infoDpm, fileExists());
  expectThat(infoDpm, fileContent(equals(expectedOneLibNoImports)));
  infoDpm.deleteSync();
  expectThat(infoDpm, not(fileExists()));

  expectThat( () => infer(["$testFilesPath/one-lib-with-imports"]), returnsNormally());
  infoDpm = new File("$testFilesPath/one-lib-with-imports/info.dpm");
  expectThat(infoDpm, fileExists());
  expectThat(infoDpm, fileContent(equals(expectedOneLibWithImports)));
  infoDpm.deleteSync();
  expectThat(infoDpm, not(fileExists()));

  print("ok");
}

