// Generated by BUCKLESCRIPT, PLEASE EDIT WITH CARE
'use strict';

var Caml_primitive = require("bs-platform/lib/js/caml_primitive.js");
var Translator$AgdaModeVscode = require("./Translator.bs.js");

function Impl(Editor) {
  var make = function (param) {
    return {
            symbol: undefined,
            tail: "",
            translation: Translator$AgdaModeVscode.translate(""),
            candidateIndex: 0
          };
  };
  var isEmpty = function (self) {
    if (self.symbol === undefined) {
      return self.tail === "";
    } else {
      return false;
    }
  };
  var toSequence = function (self) {
    var match = self.symbol;
    if (match !== undefined) {
      return match[1] + self.tail;
    } else {
      return self.tail;
    }
  };
  var toSurface = function (self) {
    var match = self.symbol;
    if (match !== undefined) {
      return match[0] + self.tail;
    } else {
      return self.tail;
    }
  };
  var toString = function (self) {
    return "\"" + (toSurface(self) + ("\"[" + (toSequence(self) + "]")));
  };
  var moveUp = function (self) {
    return {
            symbol: self.symbol,
            tail: self.tail,
            translation: self.translation,
            candidateIndex: Caml_primitive.caml_int_max(0, self.candidateIndex - 10 | 0)
          };
  };
  var moveRight = function (self) {
    return {
            symbol: self.symbol,
            tail: self.tail,
            translation: self.translation,
            candidateIndex: Caml_primitive.caml_int_min(self.translation.candidateSymbols.length - 1 | 0, self.candidateIndex + 1 | 0)
          };
  };
  var moveDown = function (self) {
    return {
            symbol: self.symbol,
            tail: self.tail,
            translation: self.translation,
            candidateIndex: Caml_primitive.caml_int_min(self.translation.candidateSymbols.length - 1 | 0, self.candidateIndex + 10 | 0)
          };
  };
  var moveLeft = function (self) {
    return {
            symbol: self.symbol,
            tail: self.tail,
            translation: self.translation,
            candidateIndex: Caml_primitive.caml_int_max(0, self.candidateIndex - 1 | 0)
          };
  };
  var reflectEditorChange = function (self, start, change) {
    var sequence = toSequence(self);
    var insertStartInTextEditor = change.offset - start | 0;
    var match = self.symbol;
    var insertStart = match !== undefined ? (insertStartInTextEditor + match[1].length | 0) - match[0].length | 0 : insertStartInTextEditor;
    var insertEnd = insertStart + change.replaceLength | 0;
    var beforeInsertedText = sequence.substring(0, insertStart);
    var afterInsertedText = sequence.substring(insertEnd);
    var newSequence = beforeInsertedText + (change.insertText + afterInsertedText);
    var translation = Translator$AgdaModeVscode.translate(newSequence);
    var symbol = translation.symbol;
    if (symbol !== undefined) {
      var buffer_symbol = /* tuple */[
        symbol,
        newSequence
      ];
      var buffer_candidateIndex = self.candidateIndex;
      var buffer = {
        symbol: buffer_symbol,
        tail: "",
        translation: translation,
        candidateIndex: buffer_candidateIndex
      };
      return /* tuple */[
              buffer,
              toSurface(buffer)
            ];
    }
    if (translation.further) {
      if (newSequence.includes(sequence)) {
        var diff = newSequence.substring(sequence.length);
        var buffer_symbol$1 = self.symbol;
        var buffer_tail = self.tail + diff;
        var buffer_candidateIndex$1 = self.candidateIndex;
        var buffer$1 = {
          symbol: buffer_symbol$1,
          tail: buffer_tail,
          translation: translation,
          candidateIndex: buffer_candidateIndex$1
        };
        return /* tuple */[
                buffer$1,
                undefined
              ];
      }
      var buffer_candidateIndex$2 = self.candidateIndex;
      var buffer$2 = {
        symbol: undefined,
        tail: newSequence,
        translation: translation,
        candidateIndex: buffer_candidateIndex$2
      };
      return /* tuple */[
              buffer$2,
              toSurface(buffer$2)
            ];
    }
    var buffer_symbol$2 = self.symbol;
    var buffer_tail$1 = self.tail;
    var buffer_candidateIndex$3 = self.candidateIndex;
    var buffer$3 = {
      symbol: buffer_symbol$2,
      tail: buffer_tail$1,
      translation: translation,
      candidateIndex: buffer_candidateIndex$3
    };
    return /* tuple */[
            buffer$3,
            undefined
          ];
  };
  return {
          make: make,
          isEmpty: isEmpty,
          toSequence: toSequence,
          toSurface: toSurface,
          toString: toString,
          moveUp: moveUp,
          moveRight: moveRight,
          moveDown: moveDown,
          moveLeft: moveLeft,
          reflectEditorChange: reflectEditorChange
        };
}

exports.Impl = Impl;
/* Translator-AgdaModeVscode Not a pure module */