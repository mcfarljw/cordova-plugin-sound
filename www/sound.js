var exec = require('cordova/exec')

module.exports = {
  play: function (path, track) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'play', [path, track || 'default'])
      }
    )
  },
  stop: function (track) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'stop', [track || 'default'])
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
