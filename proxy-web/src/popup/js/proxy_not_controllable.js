(function() {
  function closePopup() {
    window.top.close();
    // If the popup is opened as a tab, the above won't work. Let's reload then.
    document.body.style.opacity = 0;
    setTimeout(function() { history.go(0); }, 300);
  }
  var closeButton = document.getElementById('js-close');
  closeButton.addEventListener('click', closePopup, false);

  var manageButton = document.getElementById('js-manage-ext');
  manageButton.addEventListener('click', function () {
    ProxyTargetPopup.openManage(closePopup);
  }, false);

  var learnMoreButton = document.getElementById('js-nc-learn-more');
  learnMoreButton.addEventListener('click', function () {
    ProxyTargetPopup.openOptions('#!/general', closePopup);
  }, false);

  closeButton.textContent = ProxyTargetPopup.getMessage('dialog_cancel');
  learnMoreButton.textContent = 'Learn More'
    //ProxyTargetPopup.getMessage('popup_proxyNotControllableLearnMore');
  manageButton.textContent = ProxyTargetPopup.getMessage(
    'popup_proxyNotControllableManage');


  ProxyTargetPopup.getState([
    'proxyNotControllable',
  ], function(err, state) {
    var reason = state.proxyNotControllable;
    var messageElement = document.getElementById('js-nc-text');
    var detailsElement = document.getElementById('js-nc-details');
    messageElement.textContent = ProxyTargetPopup.getMessage(
      'popup_proxyNotControllable_' + reason);
    var detailsMessage = ProxyTargetPopup.getMessage(
      'popup_proxyNotControllableDetails_' + reason);
    if (!detailsMessage) detailsMessage = ProxyTargetPopup.getMessage(
      'popup_proxyNotControllableDetails');

    detailsElement.textContent = detailsMessage;
  });
})();
