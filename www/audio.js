var exec = require('cordova/exec');

module.exports = {
  play: function (path, volume, rate) {
    return new Promise(
      function (resolve, reject) {
        exec(resolve, reject, 'AudioPlugin', 'play', [path, volume || 1, rate || 1]);
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
