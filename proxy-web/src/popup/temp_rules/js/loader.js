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
      ProxyTargetPopup.getTempRules(function(err, tempProfileRules){
        window.ProxyPopup.state = state;
        window.ProxyPopup.tempProfileRules = tempProfileRules;
        import('./index.js')
      })
    });
  }
  init();
});
