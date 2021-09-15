open Belt

// https://github.com/agda/agda/blob/master/src/full/Agda/Interaction/Highlighting/Precise.hs
module Aspect = {
  // https://www.gnu.org/software/emacs/manual/html_node/emacs/Faces.html
  type face =
    | Background(string)
    | Foreground(string)

  type style =
    | Noop // don't do anything
    | Themed(face, face) // under light & dark themes

  // a mix of Aspect, OtherAspect and NameKind
  type t =
    | // the Aspect part
    Comment
    | Keyword
    | String
    | Number
    | Symbol
    | PrimitiveType
    | Pragma
    | Background
    | Markup
    | // the OtherAspect part
    Error
    | DottedPattern
    | UnsolvedMeta
    | UnsolvedConstraint
    | TerminationProblem
    | PositivityProblem
    | Deadcode
    | CoverageProblem
    | IncompletePattern
    | TypeChecks
    | CatchallClause
    | ConfluenceProblem
    | // the NameKind part
    Bound
    | Generalizable
    | ConstructorInductive
    | ConstructorCoInductive
    | Datatype
    | Field
    | Function
    | Module
    | Postulate
    | Primitive
    | Record
    | Argument
    | Macro
    | // when the second field of Aspect.Name is True
    Operator

  let toString = x =>
    switch x {
    // the Aspect part
    | Comment => "Comment"
    | Keyword => "Keyword"
    | String => "String"
    | Number => "Number"
    | Symbol => "Symbol"
    | PrimitiveType => "PrimitiveType"
    | Pragma => "Pragma"
    | Background => "Background"
    | Markup => "Markup"
    // the OtherAspect part
    | Error => "Error"
    | DottedPattern => "DottedPattern"
    | UnsolvedMeta => "UnsolvedMeta"
    | UnsolvedConstraint => "UnsolvedConstraint"
    | TerminationProblem => "TerminationProblem"
    | PositivityProblem => "PositivityProblem"
    | Deadcode => "Deadcode"
    | CoverageProblem => "CoverageProblem"
    | IncompletePattern => "IncompletePattern"
    | TypeChecks => "TypeChecks"
    | CatchallClause => "CatchallClause"
    | ConfluenceProblem => "ConfluenceProblem"
    // the NameKind part
    | Bound => "Bound"
    | Generalizable => "Generalizable"
    | ConstructorInductive => "ConstructorInductive"
    | ConstructorCoInductive => "ConstructorCoInductive"
    | Datatype => "Datatype"
    | Field => "Field"
    | Function => "Function"
    | Module => "Module"
    | Postulate => "Postulate"
    | Primitive => "Primitive"
    | Record => "Record"
    | Argument => "Argument"
    | Macro => "Macro"
    // when the second field of Aspect.Name is True
    | Operator => "Operator"
    }

  // namespace
  // type, class, enum, interface, struct, typeParameter
  // parameter, variable, property, enumMember, event
  // function, member, macro
  // label
  // comment, string, keyword, number, regexp, operator

  
  let parse = x =>
    switch x {
    | "comment" => Comment
    | "keyword" => Keyword
    | "string" => String
    | "number" => Number
    | "symbol" => Symbol
    | "primitivetype" => PrimitiveType
    | "pragma" => Pragma
    | "background" => Background
    | "markup" => Markup

    | "error" => Error
    | "dottedpattern" => DottedPattern
    | "unsolvedmeta" => UnsolvedMeta
    | "unsolvedconstraint" => UnsolvedConstraint
    | "terminationproblem" => TerminationProblem
    | "positivityproblem" => PositivityProblem
    | "deadcode" => Deadcode
    | "coverageproblem" => CoverageProblem
    | "incompletepattern" => IncompletePattern
    | "typechecks" => TypeChecks
    | "catchallclause" => CatchallClause
    | "confluenceproblem" => ConfluenceProblem

    | "bound" => Bound
    | "generalizable" => Generalizable
    | "inductiveconstructor" => ConstructorInductive
    | "coinductiveconstructor" => ConstructorCoInductive
    | "datatype" => Datatype
    | "field" => Field
    | "function" => Function
    | "module" => Module
    | "postulate" => Postulate
    | "primitive" => Primitive
    | "record" => Record
    | "argument" => Argument
    | "macro" => Macro

    | "operator" => Operator
    | _ => Operator
    }

  let toStyle = x =>
    switch x {
    | Comment => Themed(Foreground("#B0B0B0"), Foreground("#505050"))
    | Keyword => Themed(Foreground("#CD6600"), Foreground("#FF9932"))
    | String => Themed(Foreground("#B22222"), Foreground("#DD4D4D"))
    | Number => Themed(Foreground("#800080"), Foreground("#9010E0"))
    | Symbol => Themed(Foreground("#404040"), Foreground("#BFBFBF"))
    | PrimitiveType => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Pragma => Noop
    | Background => Noop
    | Markup => Noop
    | Error => Themed(Foreground("#FF0000"), Foreground("#FF0000"))
    | DottedPattern => Noop
    | UnsolvedMeta => Themed(Background("#FFFF00"), Background("#806B00"))
    | UnsolvedConstraint => Themed(Background("#FFFF00"), Background("#806B00"))
    | TerminationProblem => Themed(Background("#FFA07A"), Background("#802400"))
    | PositivityProblem => Themed(Background("#CD853F"), Background("#803F00"))
    | Deadcode => Themed(Background("#A9A9A9"), Background("#808080"))
    | CoverageProblem => Themed(Background("#F5DEB3"), Background("#805300"))
    | IncompletePattern => Themed(Background("#800080"), Background("#800080"))
    | TypeChecks => Noop
    | CatchallClause => Themed(Background("#F5F5F5"), Background("#404040"))
    | ConfluenceProblem => Themed(Background("#FFC0CB"), Background("#800080"))
    | Bound => Noop
    | Generalizable => Noop
    | ConstructorInductive => Themed(Foreground("#008B00"), Foreground("#29CC29"))
    | ConstructorCoInductive => Themed(Foreground("#996600"), Foreground("#FFEA75"))
    | Datatype => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Field => Themed(Foreground("#EE1289"), Foreground("#F570B7"))
    | Function => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Module => Themed(Foreground("#800080"), Foreground("#CD80FF"))
    | Postulate => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Primitive => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Record => Themed(Foreground("#0000CD"), Foreground("#8080FF"))
    | Argument => Noop
    | Macro => Themed(Foreground("#458B74"), Foreground("#73BAA2"))
    | Operator => Noop
    }
}

module Token = Parser.SExpression
open Token

module Info = {
  type filepath = string
  type t = {
    start: int, // agda offset
    end_: int, // agda offset
    aspects: array<Aspect.t>, // a list of names of aspects
    isTokenBased: bool,
    note: option<string>,
    source: option<(filepath, int)>, // The defining module and the position in that module
  }
  let toString = self =>
    "Annotation " ++
    (string_of_int(self.start) ++
    (" " ++
    (string_of_int(self.end_) ++
    (" " ++
    (Util.Pretty.list(List.fromArray(self.aspects)) ++
    switch self.source {
    | None => ""
    | Some((s, i)) => s ++ (" " ++ string_of_int(i))
    })))))
  let parse: Token.t => option<t> = x =>
    switch x {
    | A(_) => None
    | L(xs) =>
      switch xs {
      | [A(start'), A(end_'), aspects, _, _, L([A(filepath), _, A(index')])] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.flatMap(end_ =>
            int_of_string_opt(index')->Option.map(index => {
              start: start - 1,
              end_: end_ - 1,
              aspects: flatten(aspects)->Array.map(Aspect.parse),
              isTokenBased: false, // NOTE: fix this
              note: None, // NOTE: fix this
              source: Some((filepath, index)),
            })
          )
        )

      | [A(start'), A(end_'), aspects] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.map(end_ => {
            start: start - 1,
            end_: end_ - 1,
            aspects: flatten(aspects)->Array.map(Aspect.parse),
            isTokenBased: false, // NOTE: fix this
            note: None, // NOTE: fix this
            source: None,
          })
        )
      | [A(start'), A(end_'), aspects, _] =>
        int_of_string_opt(start')->Option.flatMap(start =>
          int_of_string_opt(end_')->Option.map(end_ => {
            start: start - 1,
            end_: end_ - 1,
            aspects: flatten(aspects)->Array.map(Aspect.parse),
            isTokenBased: false, // NOTE: fix this
            note: None, // NOTE: fix this
            source: None,
          })
        )
      | _ => None
      }
    }
  let parseDirectHighlightings: array<Token.t> => array<t> = tokens =>
    tokens->Js.Array.sliceFrom(2, _)->Array.map(parse)->Array.keepMap(x => x)

  let decode: Json.Decode.decoder<t> = {
    open Json.Decode
    Util.Decode.tuple6(
      int,
      int,
      array(string),
      bool,
      optional(string),
      optional(pair(string, int)),
    ) |> map(((start, end_, aspects, isTokenBased, note, source)) => {
      start: start - 1,
      end_: end_ - 1,
      aspects: aspects->Array.map(Aspect.parse),
      isTokenBased: isTokenBased,
      note: note,
      source: source,
    })
  }
}

module Infos = {
  type t = Infos(bool, array<Info.t>)
  let decode: Json.Decode.decoder<t> = {
    open Json.Decode
    pair(bool, array(Info.decode)) |> map(((keepHighlighting, xs)) => Infos(keepHighlighting, xs))
  }

  let toInfos = x =>
    switch x {
    | Infos(_, xs) => xs
    }
}
