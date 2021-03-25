open Belt

// For throttling Requests send to Agda
// 1 Request to Agda at a time
module RequestQueue: {
  type t
  let make: unit => t
  // only gets resolved after the Request has been handled
  let push: (t, Request.t => Promise.t<unit>, Request.t) => Promise.t<unit>
} = {
  type t = {
    queue: array<unit => Promise.t<unit>>,
    mutable busy: bool,
  }

  let make = () => {
    queue: [],
    busy: false,
  }

  let rec kickStart = self =>
    if self.busy {
      // busy running, just leave it be
      ()
    } else {
      // pop the front of the queue
      switch Js.Array.shift(self.queue) {
      | None => () // nothing to pop
      | Some(thunk) =>
        self.busy = true
        thunk()->Promise.get(() => {
          self.busy = false
          kickStart(self)
        })
      }
    }

  // only gets resolved after the Request has been handled
  let push = (self, sendRequestAndHandleResponses, request) => {
    let (promise, resolve) = Promise.pending()
    let thunk = () => sendRequestAndHandleResponses(request)->Promise.tap(resolve)
    // push to the back of the queue
    Js.Array.push(thunk, self.queue)->ignore
    // kick start
    kickStart(self)
    promise
  }
}

type viewCache =
  Event(View.EventToView.t) | Request(View.Request.t, View.Response.t => Promise.t<unit>)

type t = {
  devMode: bool,
  mutable editor: VSCode.TextEditor.t,
  mutable document: VSCode.TextDocument.t,
  view: ViewController.t,
  mutable viewCache: option<viewCache>,
  mutable goals: array<Goal.t>,
  mutable decoration: Decoration.t,
  mutable cursor: option<VSCode.Position.t>,
  editorIM: IM.t,
  promptIM: IM.t,
  mutable subscriptions: array<VSCode.Disposable.t>,
  // for self destruction
  onRemoveFromRegistry: Chan.t<unit>,
  // Agda Request queue
  mutable agdaRequestQueue: RequestQueue.t,
}
type state = t

// control the scope of command key-binding
module Context = {
  // input method related key-bindings
  let setPrompt = value => VSCode.Commands.setContext("agdaModePrompting", value)->ignore
  let setIM = value => VSCode.Commands.setContext("agdaModeTyping", value)->ignore
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  View
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module type View = {
  let activate: state => unit
  let reveal: state => unit
  // display stuff
  let display: (state, View.Header.t, View.Body.t) => Promise.t<unit>
  // let displayEmacs: (state, View.Body.Emacs.t, View.Header.t, string) => Promise.t<unit>
  let displayOutOfGoalError: state => Promise.t<unit>
  let displayConnectionError: (state, Connection.Error.t) => Promise.t<unit>
  let displayConnectionStatus: (state, Connection.status) => Promise.t<unit>
  // Input Method
  let updateIM: (state, View.EventToView.InputMethod.t) => Promise.t<unit>
  let updatePromptIM: (state, string) => Promise.t<unit>
  // Prompt
  let prompt: (state, View.Header.t, View.Prompt.t, string => Promise.t<unit>) => Promise.t<unit>
  let interruptPrompt: state => Promise.t<unit>
}

module View: View = {
  let sendEvent = (state, event) => {
    state.viewCache = Some(Event(event))
    state.view->ViewController.sendEvent(event)
  }
  let sendRequest = (state, request, callback) => {
    state.viewCache = Some(Request(request, callback))
    state.view->ViewController.sendRequest(request, callback)
  }

  let activate = state =>
    state.viewCache->Option.forEach(content =>
      switch content {
      | Event(event) => state.view->ViewController.sendEvent(event)->ignore
      | Request(request, callback) =>
        state.view->ViewController.sendRequest(request, callback)->ignore
      }
    )

  let reveal = state => {
    state.view->ViewController.reveal
  }

  // display stuff
  let display = (state, header, body) => sendEvent(state, Display(header, body))
  // let displayEmacs = (state, kind, header, body) =>
  //   sendEvent(state, Display(header, Emacs(kind, View.Header.toString(header), body)))
  let displayOutOfGoalError = state =>
    display(
      state,
      Error("Out of goal"),
      [Component.Item.plainText("Please place the cursor in a goal")],
    )

  let displayConnectionError = (state, error) => {
    let (header, body) = Connection.Error.toString(error)
    display(state, Error("Connection Error: " ++ header), [Component.Item.plainText(body)])
  }

  // display connection status
  let displayConnectionStatus = (state, status) =>
    switch status {
    | Connection.Emacs(_) => sendEvent(state, SetStatus("Emacs"))
    | LSP(ViaStdIO(_, _), _) => sendEvent(state, SetStatus("LSP"))
    | LSP(ViaTCP(_), _) => sendEvent(state, SetStatus("LSP (TCP)"))
    }

  // update the Input Method
  let updateIM = (state, event) => sendEvent(state, InputMethod(event))
  let updatePromptIM = (state, content) => sendEvent(state, PromptIMUpdate(content))

  // Header + Prompt
  let prompt = (
    state,
    header,
    prompt,
    callbackOnPromptSuccess: string => Promise.t<unit>,
  ): Promise.t<unit> => {
    // focus on the panel before prompting
    Context.setPrompt(true)
    state.view->ViewController.focus

    // send request to view
    sendRequest(state, Prompt(header, prompt), response =>
      switch response {
      | PromptSuccess(result) =>
        callbackOnPromptSuccess(result)->Promise.map(() => {
          // put the focus back to the editor after prompting
          Context.setPrompt(false)
          state.document->Editor.focus
        })
      | PromptInterrupted => Promise.resolved()
      }
    )
  }
  let interruptPrompt = state => sendEvent(state, PromptInterrupt)
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  Connection
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// module type Connection = {
//   // let reconnect: state => Promise.t<result<Connection.Emacs.t, Connection.Error.t>>
//   // let destroy: state => Promise.t<unit>
//   // let sendRequest: (state, Response.t => Promise.t<unit>, Request.t) => Promise.t<unit>
// }
// module Connection: Connection = {
//   // let connect = state =>
//   //   switch state.connection {
//   //   | None =>
//   //     switch state.agdaLanguageServerVersion {
//   //     | None => Connection.Emacs.make()->Promise.tapOk(conn => state.connection = Some(conn))
//   //     | Some(version) =>
//   //       Js.log("[LSP] Connecting with agda-" ++ version)
//   //       Connection.Emacs.make()->Promise.tapOk(conn => state.connection = Some(conn))
//   //     }
//   //   | Some(connection) => Promise.resolved(Ok(connection))
//   //   }
//   // let disconnect = state =>
//   //   switch state.connection {
//   //   | None => Promise.resolved()
//   //   | Some(connection) =>
//   //     state.connection = None
//   //     Connection.Emacs.destroy(connection)
//   //   }

//   // let reconnect = state =>
//   //   switch state.connection {
//   //   | Emacs(conn, version) =>
//   //     Connection.Emacs.destroy(conn)
//   //     ->Promise.flatMap(Connection.Emacs.make)
//   //     ->Promise.flatMapOk(conn => {
//   //       state.connection = Emacs(conn, version)
//   //       View.setStatus(state, "emacs")->Promise.map(_ => Ok(conn))
//   //     })
//   //   | _ => Promise.resolved(Error(Connection.Error.NotConnectedYet))
//   //   }

//   // let destroy = state =>
//   //   switch state.connection {
//   //   | Emacs(conn, _) => conn->Connection.Emacs.destroy
//   //   | _ => Promise.resolved()
//   //   }

//   // let sendRequestAndHandleResponses = (
//   //   state: state,
//   //   handleResponse: Response.t => Promise.t<unit>,
//   //   request: Request.t,
//   // ): Promise.t<unit> => {
//   //   let handleResult = result =>
//   //     switch result {
//   //     | Error(error) =>
//   //       let (head, body) = Connection.Error.toString(error)
//   //       View.display(state, Error(head), [Component.Item.plainText(body)])
//   //     | Ok(response) => handleResponse(response)
//   //     }
//   //   let handleResultLSP = result =>
//   //     switch result {
//   //     | Error(error) => handleResult(Error(Connection.Error.LSP(error)))
//   //     | Ok(response) => handleResult(Ok(response))
//   //     }

//   //   // encode the Request to some string
//   //   let encodeRequest = version => {
//   //     let filepath = state.document->VSCode.TextDocument.fileName->Parser.filepath
//   //     let libraryPath = Config.getLibraryPath()
//   //     let highlightingMethod = Config.getHighlightingMethod()
//   //     let backend = Config.getBackend()
//   //     Request.encode(
//   //       state.document,
//   //       version,
//   //       filepath,
//   //       backend,
//   //       libraryPath,
//   //       highlightingMethod,
//   //       request,
//   //     )
//   //   }

//   //   switch state.connection {
//   //   | Emacs(conn, version) =>
//   //     // this promise gets resolved after all Responses have been received and handled
//   //     Connection.Emacs.sendRequest(conn, encodeRequest(version), handleResult)->Promise.flatMap(result =>
//   //       switch result {
//   //       | Error(error) => View.displayConnectionError(state, error)
//   //       | Ok() => Promise.resolved()
//   //       }
//   //     )
//   //   | LSP(version, _viaTCP) =>
//   //     Connection.LSP.sendRequest(encodeRequest(version), handleResultLSP)->Promise.flatMap(result =>
//   //       switch result {
//   //       | Error(error) => View.displayConnectionError(state, Connection.Error.LSP(error))
//   //       | Ok() => Promise.resolved()
//   //       }
//   //     )
//   //   | Nothing(error) => View.displayConnectionError(state, error)
//   //   }
//   // }

//   let sendRequestAndHandleResponses = (state, request, handler) => {
//     let handleResult = result =>
//       switch result {
//       | Error(error) =>
//         let (head, body) = Connection.Error.toString(error)
//         View.display(state, Error(head), [Component.Item.plainText(body)])
//       | Ok(response) => handler(response)
//       }
//     Connection.sendRequest(state.document, request, handleResult)->Promise.flatMap(result =>
//       switch result {
//       | Error(error) => View.displayConnectionError(state, error)
//       | Ok() => Promise.resolved()
//       }
//     )
//   }

//   let sendRequest = (
//     state: state,
//     handleResponse: Response.t => Promise.t<unit>,
//     request: Request.t,
//   ): Promise.t<unit> =>
//     state.agdaRequestQueue->RequestQueue.push(
//       request => sendRequestAndHandleResponses(state, request, handleResponse),
//       request,
//     )
// }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  State
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

let sendRequest = (
  state: state,
  handleResponse: Response.t => Promise.t<unit>,
  request: Request.t,
): Promise.t<unit> => {
  let sendRequestAndHandleResponses = (state, request, handler) => {
    let handleResult = result =>
      switch result {
      | Error(error) =>
        let (head, body) = Connection.Error.toString(error)
        View.display(state, Error(head), [Component.Item.plainText(body)])
      | Ok(response) => handler(response)
      }
    Connection.sendRequest(
      Config.useAgdaLanguageServer(),
      state.devMode,
      state.document,
      request,
      handleResult,
    )->Promise.flatMap(result =>
      switch result {
      | Error(error) => View.displayConnectionError(state, error)
      | Ok(status) => View.displayConnectionStatus(state, status)
      }
    )
  }

  state.agdaRequestQueue->RequestQueue.push(
    request => sendRequestAndHandleResponses(state, request, handleResponse),
    request,
  )
}

// construction/destruction
let destroy = (state, alsoRemoveFromRegistry) => {
  if alsoRemoveFromRegistry {
    state.onRemoveFromRegistry->Chan.emit()
  }
  state.onRemoveFromRegistry->Chan.destroy
  state.goals->Array.forEach(Goal.destroy)
  state.decoration->Decoration.destroy
  state.subscriptions->Array.forEach(VSCode.Disposable.dispose)
  Connection.stop()
  // TODO: delete files in `.indirectHighlightingFileNames`
}

let make = (chan, editor, view, devMode) => {
  editor: editor,
  document: VSCode.TextEditor.document(editor),
  view: view,
  viewCache: None,
  goals: [],
  decoration: Decoration.make(),
  cursor: None,
  editorIM: IM.make(chan),
  promptIM: IM.make(chan),
  subscriptions: [],
  onRemoveFromRegistry: Chan.make(),
  agdaRequestQueue: RequestQueue.make(),
  devMode: devMode
}
