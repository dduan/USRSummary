import Foundation
import IndexStoreDB
import Pathos
#if canImport(Darwin)
import func Darwin.fputs
import func Darwin.exit
import var Darwin.EXIT_FAILURE
import var Darwin.stderr
#else
import func Glibc.fputs
import func Glibc.exit
import var Glibc.EXIT_FAILURE
import var Glibc.stderr
#endif
import XCTest

func bail(_ message: String) -> Never {
    fputs(message, stderr)
    exit(EXIT_FAILURE)
}

func shell(_ command: String) throws -> Data {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/bash")
    task.arguments = ["-c", command]
    let output = Pipe()
    task.standardOutput = output
    try task.run()
    task.waitUntilExit()
    return output.fileHandleForReading.readDataToEndOfFile()
}

func defaultPathToLibIndexStore() throws -> String {
    let outputData = try shell("swift -print-target-info")
    let json = try JSONSerialization.jsonObject(with: outputData)
    let pathToSwift = ((json as! [String: Any])["paths"] as! [String: Any])["runtimeResourcePath"] as! String
#if os(macOS)
    return "\(Path(pathToSwift).parent.joined(with: "libIndexStore.dylib"))"
#else
    return "\(Path(pathToSwift).parent.joined(with: "libIndexStore.so"))"
#endif
}


var tempPath: String = ""
do {
    tempPath = (try Path.makeTemporaryDirectory()).description
} catch {
    bail("Failed to make a temporary directory")
}

let libIndexStore: IndexStoreLibrary
do {
    libIndexStore = try IndexStoreLibrary(dylibPath: defaultPathToLibIndexStore())
} catch {
    bail("Could not initialize libIndexStore")
}

guard let indexStore = try? IndexStoreDB(
    storePath: ".build/debug/index/store",
    databasePath: tempPath,
    library: libIndexStore
) else {
    bail("Could not initialize index store")
}

indexStore.pollForUnitChangesAndWait()

var defs = [String: [String]]()

let occurs = indexStore.canonicalOccurrences(
    containing: "",
    anchorStart: false,
    anchorEnd: true,
    subsequence: false,
    ignoreCase: true
)
.filter { occur in
    occur.roles.contains(.definition) &&
    occur.location.isSystem &&
    !occur.location.moduleName.isEmpty
}


for occur in occurs {
    defs[occur.location.moduleName, default: []].append("\(occur.symbol.name)\t\(occur.symbol.usr)")
}

print("Symbol Name\tUSR\tModule Name")
for (module, list) in defs.sorted(by: { $0.key < $1.key }) {
    for symbol in list.sorted() {
        print("\(symbol)\t\(module)")
    }
}
