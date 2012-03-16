// Copyright (c) 2012, Ladislav Thon. All rights reserved. Use of this source
// code is governed by a BSD-style license that can be found in the LICENSE file.

ImportResolver _mainResolver;

String resolveLocally(String importSpecStr) {
  if (_mainResolver == null) {
    _mainResolver = new RuntimeAwareImportResolver(new LocalUserRepository());
  }

  ImportSpecification spec = new ImportSpecification.parse(importSpecStr);
  Import import = _mainResolver.resolve(spec);
  return import.url;
}

