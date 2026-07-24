if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/sw.js', { scope: '/' }).then(function(reg) {
    reg.onupdatefound = function() {
      var installingWorker = reg.installing;
      installingWorker.onstatechange = function() {
        if (installingWorker.state === 'installed' && navigator.serviceWorker.controller) {
          window.location.reload();
        }
      };
    };
  });
}
