{{flutter_js}}
{{flutter_build_config}}

(function () {
  function showBootError(message) {
    var existing = document.getElementById('boot-error');
    var fullMessage = 'UA: ' + navigator.userAgent + '\n' + message;
    if (existing) {
      existing.textContent = fullMessage;
      return;
    }
    var pre = document.createElement('pre');
    pre.id = 'boot-error';
    pre.style.whiteSpace = 'pre-wrap';
    pre.style.padding = '12px';
    pre.style.margin = '12px';
    pre.style.background = '#1a1a1a';
    pre.style.color = '#ffb4b4';
    pre.style.fontFamily = 'monospace';
    pre.style.fontSize = '12px';
    pre.textContent = fullMessage;
    document.body.appendChild(pre);
  }

  window.addEventListener('error', function (event) {
    var msg =
      'JS error: ' + (event.message || 'unknown') +
      '\nfile: ' + (event.filename || 'n/a') +
      '\nline: ' + (event.lineno || 0) + ':' + (event.colno || 0) +
      '\nstack: ' + (event.error && event.error.stack ? event.error.stack : 'n/a');
    showBootError(msg);
  });

  window.addEventListener('unhandledrejection', function (event) {
    var reason = event.reason && event.reason.toString ? event.reason.toString() : 'unknown';
    var stack = event.reason && event.reason.stack ? '\nstack: ' + event.reason.stack : '';
    showBootError('Unhandled promise rejection: ' + reason + stack);
  });

  try {
    _flutter.loader
      .load({
        // Disable service worker registration to avoid stale cache on mobile browsers.
        serviceWorkerSettings: null,
      })
      .catch(function (e) {
        var stack = e && e.stack ? '\nstack: ' + e.stack : '';
        showBootError('Flutter bootstrap failed: ' + e + stack);
      });
  } catch (e) {
    var stack = e && e.stack ? '\nstack: ' + e.stack : '';
    showBootError('Bootstrap exception: ' + e + stack);
  }
})();
