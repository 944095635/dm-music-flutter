import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    self.setContentSize(NSSize(width: 375, height: 812))
    self.center()
    RegisterGeneratedPlugins(registry: flutterViewController)
    super.awakeFromNib()
  }
}
