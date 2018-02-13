import AudioToolbox

@objc(SoundPlugin)
class SoundPlugin : CDVPlugin {

  @objc(pluginInitialize)
  override func pluginInitialize() {}

  @objc(play:)
  func play(command: CDVInvokedUrlCommand) {
    DispatchQueue.global(qos: .userInitiated).async {
      let trimmingSet = CharacterSet.init(charactersIn: "/")
      let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
      let path = command.arguments[0] as? String ?? ""
      let pathURL = NSURL(fileURLWithPath: path)
      let pathExtension = pathURL.pathExtension ?? "mp3"
      let pathName = pathURL.deletingPathExtension?.path ?? ""
      let trimmedPath = path.trimmingCharacters(in: trimmingSet)
      let trimmedPathName = pathName.trimmingCharacters(in: trimmingSet)

      let manager = FileManager.default
      let documents = try! manager.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      let documentUrl = documents.appendingPathComponent(trimmedPath)
      var soundUrl: URL?

      if (FileManager().fileExists(atPath: documentUrl.path)) {
        soundUrl = documentUrl
      } else {
        soundUrl = Bundle.main.url(forResource: "www/" + trimmedPathName, withExtension: pathExtension)
      }

      if (soundUrl != nil) {
        var soundId: SystemSoundID = 0

        AudioServicesCreateSystemSoundID(soundUrl! as CFURL, &soundId)

        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
          AudioServicesDisposeSystemSoundID(soundId)
        }, nil)

        AudioServicesPlaySystemSound(soundId)
      }

      self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
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
