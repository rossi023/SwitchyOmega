$script.ready('om-page-info', function() {
  document.querySelector('#js-direct .om-profile-name').textContent =
    ProxyTargetPopup.getMessage('profile_direct');
  document.querySelector('#js-system .om-profile-name').textContent =
    ProxyTargetPopup.getMessage('profile_system');
  document.querySelector('#js-addrule-label').textContent =
    ProxyTargetPopup.getMessage('popup_addCondition');
  document.querySelector('#js-option-label').textContent =
    ProxyTargetPopup.getMessage('popup_showOptions');
});
