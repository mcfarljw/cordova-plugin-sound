var exec = require('cordova/exec');

module.exports = {
  play: function (path, start, duration) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'AudioPlugin', 'play', [path, start || 0, duration || 0]);
      }
    );
  },
  release: function () {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'AudioPlugin', 'release', []);
      }
    );
  }
};
