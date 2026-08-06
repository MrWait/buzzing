import Cocoa
import FlutterMacOS
import desktop_multi_window

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMultiWindowPlugin.setOnWindowCreatedCallback { controller in
      // Register the plugin which you want access from other isolate.
      RegisterGeneratedPlugins(registry: controller)
    }

    super.awakeFromNib()

    tightenWindowButtons()
  }

  /// 将左上角原生窗口按钮（关闭/最小化/最大化）横向收紧，
  /// 使其整体落在左侧导航栏宽度（64）内，避免最大化按钮贴到导航栏边界。
  private func tightenWindowButtons() {
    // 等窗口完成首轮布局后再调整，保证 superview 与按钮 frame 已就绪。
    DispatchQueue.main.async { [weak self] in
      self?.applyTightTrafficLights()
    }
  }

  private func applyTightTrafficLights() {
    // 以当前默认按钮尺寸为基准，直径缩小到 0.8 倍。
    let scale: CGFloat = 0.8
    guard let closeButton = standardWindowButton(.closeButton),
          let superview = closeButton.superview else { return }

    let diameter = closeButton.frame.height * scale

    // 布局：关闭按钮距窗口左边框 10pt，按钮间留 7pt 间距，
    // 整组宽度约 53pt，仍落在导航栏 64 内。
    let leading: CGFloat = 10
    let gap: CGFloat = 7
    let specs: [(NSWindow.ButtonType, CGFloat)] = [
      (.closeButton, leading),
      (.miniaturizeButton, leading + diameter + gap),
      (.zoomButton, leading + (diameter + gap) * 2),
    ]

    // 三个按钮纵向居中。
    let top = (superview.bounds.height - diameter) / 2

    for (type, x) in specs {
      guard let button = standardWindowButton(type),
            let buttonSuperview = button.superview else { continue }

      button.translatesAutoresizingMaskIntoConstraints = false

      // 移除先前添加的同按钮约束，避免重复叠加。
      let old = buttonSuperview.constraints.filter { ($0.firstItem as? NSButton) == button }
      buttonSuperview.removeConstraints(old)

      let left = NSLayoutConstraint(
        item: button,
        attribute: .left,
        relatedBy: .equal,
        toItem: buttonSuperview,
        attribute: .left,
        multiplier: 1,
        constant: x
      )
      let topConstraint = NSLayoutConstraint(
        item: button,
        attribute: .top,
        relatedBy: .equal,
        toItem: buttonSuperview,
        attribute: .top,
        multiplier: 1,
        constant: top
      )
      let width = NSLayoutConstraint(
        item: button,
        attribute: .width,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: diameter
      )
      let height = NSLayoutConstraint(
        item: button,
        attribute: .height,
        relatedBy: .equal,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: diameter
      )

      buttonSuperview.addConstraints([left, topConstraint, width, height])
    }
  }
}
