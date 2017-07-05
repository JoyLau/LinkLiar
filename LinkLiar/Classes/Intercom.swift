import Foundation
import ServiceManagement

class Intercom: NSObject {

  private static var xpcConnection: NSXPCConnection?

  static func reset() {
    self.xpcConnection = nil
  }

  static func helperAlive(reply: @escaping (Bool) -> Void) {
    Log.debug("Checking helper alice")
    let helper = self.connection()?.remoteObjectProxyWithErrorHandler({ _ in
      reply(false)
      return
    }) as! HelperProtocol
    helper.version(reply: { _ in
      Log.debug("The helper responded with its version in alive check")
      reply(true)
      return
    })
  }

  static func helperVersion(reply: @escaping (Version) -> Void) {
    usingHelper(block: { helper in
      helper.version(reply: { rawVersion in
        Log.debug("The helper responded with its version")
        reply(Version(rawVersion))
      })
    })
  }

  static func createConfigDir(reply: @escaping (Bool) -> Void) {
    usingHelper(block: { helper in
      helper.createConfigDirectory(reply: { success in
        Log.debug("Helper worked on config dir creation")
        reply(success)
      })
    })
  }

  static func removeConfigDir(reply: @escaping (Bool) -> Void) {
    usingHelper(block: { helper in
      helper.removeConfigDirectory(reply: { success in
        Log.debug("Helper worked on config dir deletion")
        reply(success)
      })
    })
  }

  static func configureDaemon(reply: @escaping (Bool) -> Void) {
    Log.debug("Asking Helper to establish daemon")
    let helper = self.connection()?.remoteObjectProxyWithErrorHandler({
      error in
      Log.debug("Oh no, no connection to helper")
      Log.debug(error.localizedDescription)
      reply(false)
    }) as! HelperProtocol

    Log.debug("helper is there")
    helper.configureDaemon(reply: {
      success in
      Log.debug("Helper worked on the establishment of the daemon")
      reply(success)
    })
  }
  
  static func activateDaemon(reply: @escaping (Bool) -> Void) {
    Log.debug("Asking Helper to activate daemon")
    let helper = self.connection()?.remoteObjectProxyWithErrorHandler({
      error in
      Log.debug("Oh no, no connection to helper")
      Log.debug(error.localizedDescription)
      reply(false)
    }) as! HelperProtocol

    Log.debug("helper is there")
    helper.activateDaemon(reply: {
      success in
      Log.debug("Helper worked on the activation of the daemon")
      reply(success)
    })
  }

  static func deactivateDaemon(reply: @escaping (Bool) -> Void) {
    Log.debug("Asking Helper to deactivate daemon")
    let helper = self.connection()?.remoteObjectProxyWithErrorHandler({
      error in
      Log.debug("Oh no, no connection to helper")
      Log.debug(error.localizedDescription)
      reply(false)
    }) as! HelperProtocol

    Log.debug("helper is there")
    helper.deactivateDaemon(reply: {
      success in
      Log.debug("Helper worked on the deactivation of the daemon")
      reply(success)
    })
  }

  static func implodeHelper(reply: @escaping (Bool) -> Void) {
    usingHelper(block: { helper in
      helper.implode(reply: {
        success in
        Log.debug("Helper worked on the imploding")
        reply(success)
      })
    })
  }

  static func usingHelper(block: @escaping (HelperProtocol) -> Void) {
    Log.debug("Checking helper connection")
    let helper = self.connection()?.remoteObjectProxyWithErrorHandler({ error in
      Log.debug("Oh no, no connection to helper")
      Log.debug(error.localizedDescription)
    }) as! HelperProtocol
    block(helper)
  }

  static func connection() -> NSXPCConnection? {
    if (self.xpcConnection != nil) { return self.xpcConnection }

    self.xpcConnection = NSXPCConnection(machServiceName: Identifiers.helper.rawValue, options: NSXPCConnection.Options.privileged)
    self.xpcConnection!.exportedObject = self
    self.xpcConnection!.remoteObjectInterface = NSXPCInterface(with:HelperProtocol.self)

    self.xpcConnection!.interruptionHandler = {
      self.xpcConnection?.interruptionHandler = nil
      OperationQueue.main.addOperation(){
        self.xpcConnection = nil
        Log.debug("XPC Connection interrupted\n")
      }
    }

    self.xpcConnection!.invalidationHandler = {
      self.xpcConnection?.invalidationHandler = nil
      OperationQueue.main.addOperation(){
        self.xpcConnection = nil
        Log.debug("XPC Connection Invalidated\n")
      }
    }

    self.xpcConnection?.resume()
    return self.xpcConnection
  }

}