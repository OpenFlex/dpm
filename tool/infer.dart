// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

class FoundLibrary {
  final String file;
  final String name;

  FoundLibrary(String this.file, String this.name);
}

class InferringState {
  String scanPath;

  List<FoundLibrary> libraries;
  List<String> imports;

  InferringState(String this.scanPath) : libraries = new List<FoundLibrary>(),
      imports = new List<String>();
}

var libraryRegexp = const RegExp("#\s*library\s*\\\(\s*[\'\"](.*?)[\'\"]\s*\\\)\s*;");
var importRegexp = const RegExp("#\s*import\s*\\\(\s*[\'\"](.*?)[\'\"]\s*\\\)\s*;");

scan(String filePath, InferringState state) {
  if (!filePath.endsWith(".dart")) {
    return;
  }

  String relativePath = filePath.replaceFirst(state.scanPath, '');
  if (relativePath.startsWith('/')) {
    relativePath = relativePath.substring(1);
  }

  File file = new File(filePath);
  String content = file.readAsTextSync();
  for (Match match in libraryRegexp.allMatches(content)) {
    FoundLibrary library = new FoundLibrary(relativePath, match[1]);
    state.libraries.add(library);
  }

  for (Match match in importRegexp.allMatches(content)) {
    String import = match[1];
    if (import.startsWith("dpm:")) {
      state.imports.add(import.substring(4));
    }
  }
}

infer(List<String> args) {
  if (args.length == 0) {
    throw new ToolException("The 'infer' commands needs an argument");
  }

  if (args.length != 1) {
    throw new ToolException("The 'infer' command only accepts one argument");
  }

  String path = args[0];
  Directory dir = new Directory(path);
  if (!dir.existsSync()) {
    throw new ToolException("Directory '$path' doesn't exist");
  }

  File infoDpm = dir.file("info.dpm");
  if (infoDpm.existsSync()) {
    // TODO in this case, don't modify the descriptor, only update
    // inferred stuff (dependencies and main script)
    throw new ToolException("The 'info.dpm' descriptor already exists in '$path'");
  }

  var state = new InferringState(path);
  dir.onFile = (file) => scan(file, state);
  dir.listSync(recursive: true, fullPaths: true);

  if (state.libraries.length == 0) {
    throw new ToolException("No .dart file with '#library' directive found in '$path'");
  } else if (state.libraries.length > 1) {
    throw new ToolException("More than one .dart file with '#library' directive found in '$path");
  }
  FoundLibrary library = state.libraries[0];

  // validate syntax of package name and dependencies
  PackageId id = new PackageId("my-organization", library.name, new Version("0.1"));
  for (String import in state.imports) {
    new PackageCoordinates.parse(import);
  }
  String dependencies = Strings.join(state.imports, ', ');

  RandomAccessFile out = infoDpm.openSync(mode: FileMode.WRITE);
  out.writeStringSync("Organization: ${id.organization}\n");
  out.writeStringSync("Name: ${id.name}\n");
  out.writeStringSync("Version: ${id.version}\n");
  out.writeStringSync("Main-Script: ${library.file}\n");
  if (state.imports.length > 0) {
    out.writeStringSync("Dependencies: $dependencies\n");
  }
  out.writeStringSync("\n");
  out.closeSync();
}

