angular.module('proxy').controller 'AboutCtrl', (
  $scope, $rootScope,$modal, proxyDebug
) ->
  $scope.downloadLog = ->
    $scope.logDownloading = true
    Promise.resolve(proxyDebug.downloadLog()).then( ->
      $scope.logDownloading = false
    )
  $scope.reportIssue = ->
    $scope.issueReporting = true
    proxyDebug.reportIssue().then( ->
      $scope.issueReporting = false
    )

  $scope.showResetOptionsModal = ->
    $modal
      .open(templateUrl: 'partials/reset_options_confirm.html').result
      .then ->
        $scope.optionsReseting = true
        proxyDebug.resetOptions().then( ->
          $scope.optionsReseting = false
        )

  try
    $scope.version = proxyDebug.getProjectVersion()
  catch _
    $scope.version = '?.?.?'
