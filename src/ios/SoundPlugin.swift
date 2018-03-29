import AVFoundation

var player: AVAudioPlayer?

@objc(SoundPlugin)
class SoundPlugin : CDVPlugin {

  @objc(pluginInitialize)
  override func pluginInitialize() {}

  @objc(play:)
  func play(command: CDVInvokedUrlCommand) {
    DispatchQueue.global(qos: .userInitiated).async {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      let pluginResultError = CDVPluginResult(status: CDVCommandStatus_ERROR)
      let path = command.arguments[0] as? String ?? ""
      let pathURL = NSURL(fileURLWithPath: path)
      let pathExtension = pathURL.pathExtension ?? "mp3"
      let pathName = pathURL.deletingPathExtension?.path ?? ""

      if let soundUrl = Bundle.main.url(forResource: "www/" + pathName, withExtension: pathExtension) {
        do {
          try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
          try AVAudioSession.sharedInstance().setActive(true)

          player = try AVAudioPlayer(contentsOf: soundUrl)

          guard let player = player else { return }

          player.play()

          self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
        } catch let error {
          print(error.localizedDescription)

          self.commandDelegate.send(pluginResultError, callbackId: command.callbackId)
        }
      } else {
        self.commandDelegate.send(pluginResultError, callbackId: command.callbackId)
      }
    }
  }

  @objc(release:)
  func release(command: CDVInvokedUrlCommand) {
    DispatchQueue.global(qos: .userInitiated).async {
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
  }

}
