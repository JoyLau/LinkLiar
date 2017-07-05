import Cocoa

class DefaultSubmenu {

  func update() {
    ignoreItem.state = Config.instance.calculatedActionForDefaultInterface() == .ignore ? 1 : 0
    randomizeItem.state = Config.instance.calculatedActionForDefaultInterface() == .random ? 1 : 0
    specifyItem.state = Config.instance.calculatedActionForDefaultInterface() == .specify ? 1 : 0
    originalizeItem.state = Config.instance.calculatedActionForDefaultInterface() == .original ? 1 : 0
  }
  
  lazy var menuItem: NSMenuItem = {
    let item = NSMenuItem(title: "Default", action: nil, keyEquivalent: "")
    item.target = Controller.self
    item.submenu = self.defaultSubMenuItem
    self.update()
    return item
  }()

  private lazy var defaultSubMenuItem: NSMenu = {
    let submenu: NSMenu = NSMenu()
    submenu.addItem(self.ignoreItem)
    submenu.addItem(self.randomizeItem)
    submenu.addItem(self.specifyItem)
    submenu.addItem(self.originalizeItem)
    return submenu
  }()

  private lazy var ignoreItem: NSMenuItem = {
    let item = NSMenuItem(title: "Do nothing", action: #selector(Controller.ignoreDefaultInterface), keyEquivalent: "")
    item.target = Controller.self
    return item
  }()

  private lazy var randomizeItem: NSMenuItem = {
    let item = NSMenuItem(title: "Random", action: #selector(Controller.randomizeDefaultInterface), keyEquivalent: "")
    item.target = Controller.self
    return item
  }()

  private lazy var specifyItem: NSMenuItem = {
    let item = NSMenuItem(title: "Define manually", action: #selector(Controller.specifyDefaultInterface), keyEquivalent: "")
    item.target = Controller.self
    return item
  }()

  private lazy var originalizeItem: NSMenuItem = {
    let item = NSMenuItem(title: "Keep original", action: #selector(Controller.originalizeDefaultInterface), keyEquivalent: "")
    item.target = Controller.self
    return item
  }()

}