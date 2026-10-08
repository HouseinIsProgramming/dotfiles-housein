// Mac port of omarchy's focus-or-back for web apps living in Brave tabs.
// Focus the first Brave tab whose URL contains <match> (any window),
// open <url> in a new tab if none exists, and if that tab is already focused
// jump back to the app that was frontmost before.
//
// Native instead of osascript: osascript start-up plus asking System Events
// for the frontmost app cost ~250ms per press; NSWorkspace answers instantly.
// Built on demand by brave-focus-or-back.sh.
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else {
  FileHandle.standardError.write("usage: brave-focus-or-back <url-match> <url>\n".data(using: .utf8)!)
  exit(1)
}

let brave = "com.brave.Browser"
let state = NSTemporaryDirectory() + "brave-focus-or-back.prev"

func quoted(_ s: String) -> String {
  "\"" + s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
}

func braveScript(_ body: String) -> String? {
  var err: NSDictionary?
  let result = NSAppleScript(source: "tell application \"Brave Browser\"\n\(body)\nend tell")!.executeAndReturnError(&err)
  if let err {
    FileHandle.standardError.write("\(err)\n".data(using: .utf8)!)
    return nil
  }
  return result.stringValue
}

func debug(_ msg: @autoclosure () -> String) {
  if ProcessInfo.processInfo.environment["AFOB_DEBUG"] != nil {
    FileHandle.standardError.write("\(msg())\n".data(using: .utf8)!)
  }
}

// activate() is ~40ms, but macOS can quietly ignore it for background
// processes (it still returns true). Confirm the switch happened, and fall
// back to `open -b` (~150ms, goes through LaunchServices) if it didn't.
func bringForward(_ bundleID: String) {
  if let app = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).first,
     app.activate(options: [.activateAllWindows]) {
    let deadline = Date().addingTimeInterval(0.15)
    while Date() < deadline {
      // frontmostApplication only updates while the run loop turns.
      RunLoop.current.run(until: Date().addingTimeInterval(0.01))
      if NSWorkspace.shared.frontmostApplication?.bundleIdentifier == bundleID { return }
    }
  }
  debug("activate didn't take for \(bundleID), using open -b")
  let open = Process()
  open.executableURL = URL(fileURLWithPath: "/usr/bin/open")
  open.arguments = ["-b", bundleID]
  try? open.run()
  open.waitUntilExit()
}

let match = quoted(args[1])
let front = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
debug("front: \(front)")

if front == brave,
   braveScript("if (count of windows) > 0 then return (URL of active tab of front window) contains \(match)") == "true" {
  debug("already focused, back to \((try? String(contentsOfFile: state, encoding: .utf8)) ?? "nothing")")
  if let prev = try? String(contentsOfFile: state, encoding: .utf8), !prev.isEmpty, prev != brave {
    bringForward(prev)
  }
  exit(0)
}

// Brave uses Chromium's dictionary: windows hold tabs directly, and a tab is
// shown by setting its window's active tab index.
_ = braveScript("""
  repeat with wi from 1 to count of windows
    set urls to URL of every tab of window wi
    repeat with ti from 1 to count of urls
      if item ti of urls contains \(match) then
        set active tab index of window wi to ti
        set index of window wi to 1
        return
      end if
    end repeat
  end repeat
  if (count of windows) is 0 then
    make new window
    set URL of active tab of window 1 to \(quoted(args[2]))
  else
    tell window 1 to make new tab with properties {URL:\(quoted(args[2]))}
  end if
  """)

bringForward(brave)
if !front.isEmpty && front != brave {
  try? front.write(toFile: state, atomically: true, encoding: .utf8)
}
