import AppKit
import ShaferAccount
import SwiftUI

@main
struct __APP__App: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        Window("__APP__", id: "main") {
            ContentView()
        }
        .commands { ShaferAccountCommands() }

        Settings {
            AccountView()
                .frame(width: 460)
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        // Before launch finishes, so a __SLUG__://activate that launched the app is caught.
        ShaferAccount.configure(product: "__SLUG__", name: "__APP__")
    }

    /// `__SLUG__://activate` from shafer.llc; anything else is the app's own.
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls where !ShaferAccount.handle(url) {
            NSLog("__APP__: unhandled URL %@", url.absoluteString)
        }
    }
}
