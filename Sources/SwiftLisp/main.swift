import Foundation

do {
  let env = try loadBaseFiles()
  for argument in CommandLine.arguments[1...] {
    let _ = try execFile(filename: argument, env: env, options: [.printParse, .printResult])
  }
} catch let error {
  print("error: \(String(describing: error))")
}

enum ExecOptions {
  case printParse
  case printResult
}

enum ParenState {
  case closed
  case open
  case invalid
}

func readInput() -> String {
  var input = ""
  while let line = readLine(strippingNewline: true) {
    input += line
  }
  return input
}

