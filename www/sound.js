var exec = require('cordova/exec')

module.exports = {
  play: function (path, volume, rate) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'play', [path])
      }
    )
  },
  release: function () {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'SoundPlugin', 'release', [])
      }
    )
  }
}
