window.UglifyJS_NoUnsafeEval = true
window.ProxyPopup = {};
$script('../../js/proxy_pac.min.js', 'proxy-pac')
$script('../../js/proxy_target_popup.js', 'om-target', function() {
  $script('../js/style.js', 'om-style')
  function init(){
    ProxyTargetPopup.getState([
      'availableProfiles',
      'currentProfileName',
      'validResultProfiles',
      'isSystemProfile',
      'currentProfileCanAddRule',
      'proxyNotControllable',
      'externalProfile',
      'showExternalProfile',
      'lastProfileNameForCondition',
      'customCss',
    ], function(err, state) {
      window.ProxyPopup.state = state;
      import('./index.js')
    });
  }
  init();
});
