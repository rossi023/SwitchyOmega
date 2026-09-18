(function() {
  handleClick('js-option', showOptions);
  handleClick('js-temprule', showTempRuleDropdown);
  handleClick('js-direct', applyProfile.bind(this, 'direct'));
  handleClick('js-system', applyProfile.bind(this, 'system'));
  ProxyPopup.addTempRule = addTempRule;
  ProxyPopup.setDefaultProfile = setDefaultProfile;
  ProxyPopup.applyProfile = applyProfile;
  return;

  function handleClick(id, handler) {
    document.getElementById(id).addEventListener('click', handler, false);
  }

  function closePopup() {
    window.top.close();
    // If the popup is opened as a tab, the above won't work. Let's reload then.
    document.body.style.opacity = 0;
    setTimeout(function() { history.go(0); }, 300);
  }

  function showOptions(e) {
    if (typeof ProxyTargetPopup !== 'undefined') {
      try {
        ProxyTargetPopup.openOptions(null, closePopup);
        e.preventDefault();
      } catch (_) {
      }
    }
  }

  function applyProfile(profileName) {
    $script.ready('om-target', function() {
      ProxyTargetPopup.applyProfile(profileName, closePopup);
    });
  }

  function setDefaultProfile(profileName, defaultProfileName) {
    $script.ready('om-target', function() {
      ProxyTargetPopup.setDefaultProfile(profileName, defaultProfileName,
        closePopup);
    });
  }

  function addTempRule(domain, profileName) {
    $script.ready('om-target', function() {
      ProxyTargetPopup.addTempRule(domain, profileName, closePopup);
    });
  }

  function showTempRuleDropdown() {
    $script.ready('om-dropdowns', function() {
      ProxyPopup.showTempRuleDropdown();
    });
  }
})();
