// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Caml_chrome_debugger = require("bs-platform/lib/js/caml_chrome_debugger.js");

var Disposable = { };

var $$Event = { };

var ExtensionContext = { };

var simple = { };

function sized(v) {
  return v;
}

var Layout = {
  simple: simple,
  sized: sized
};

var Commands = {
  Layout: Layout
};

var Uri = { };

var ViewColumn = { };

var Webview = { };

function single(uri) {
  return uri;
}

function both(dark, light) {
  return {
          dark: dark,
          light: light
        };
}

function classify(param) {
  if ((v.dark === undefined)) {
    return /* Single */Caml_chrome_debugger.variant("Single", 0, [param]);
  } else {
    return /* Both */Caml_chrome_debugger.variant("Both", 1, [
              param,
              param
            ]);
  }
}

var IconPath = {
  single: single,
  both: both,
  classify: classify
};

var Options = { };

var WebviewPanel = {
  Webview: Webview,
  IconPath: IconPath,
  Options: Options
};

var TextDocument = { };

var TextEditor = { };

var InputBoxOptions = { };

var CancellationToken = { };

var WebviewOption = { };

var $$Window = {
  InputBoxOptions: InputBoxOptions,
  CancellationToken: CancellationToken,
  WebviewOption: WebviewOption
};

var Workspace = { };

exports.Disposable = Disposable;
exports.$$Event = $$Event;
exports.ExtensionContext = ExtensionContext;
exports.Commands = Commands;
exports.Uri = Uri;
exports.ViewColumn = ViewColumn;
exports.WebviewPanel = WebviewPanel;
exports.TextDocument = TextDocument;
exports.TextEditor = TextEditor;
exports.$$Window = $$Window;
exports.Workspace = Workspace;
/* No side effect */