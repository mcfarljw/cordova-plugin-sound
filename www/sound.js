var exec = require('cordova/exec')

module.exports = {
  play: function (path, track) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'play', [path, track || 0])
      }
    )
  },
  stop: function (track) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'stop', [track || 0])
      }
    )
  },
  stopAll: function () {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'stopAll', [])
      }
    )
  }
}
