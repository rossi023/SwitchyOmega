angular.module('proxy').constant('builtinProfiles',
  OmegaPac.Profiles.builtinProfiles)

profileColors = [
  '#9ce', '#9d9', '#fa8', '#fe9', '#d497ee', '#47b', '#5b5', '#d63', '#ca0'
]
colors = [].concat(profileColors)
profileColorPalette = (colors.splice(0, 3) while colors.length)

angular.module('proxy').constant('profileColors', profileColors)
angular.module('proxy').constant('profileColorPalette', profileColorPalette)

attachedPrefix = '__ruleListOf_'
angular.module('proxy').constant 'getAttachedName', (name) ->
  attachedPrefix + name
angular.module('proxy').constant 'getParentName', (name) ->
  if name.indexOf(attachedPrefix) == 0
    name.substr(attachedPrefix.length)
  else
    undefined

charCodeUnderscore = '_'.charCodeAt(0)
angular.module('proxy').constant 'charCodeUnderscore', charCodeUnderscore
angular.module('proxy').constant 'isProfileNameHidden', (name) ->
  # Hide profiles beginning with underscore.
  name.charCodeAt(0) == charCodeUnderscore
angular.module('proxy').constant 'isProfileNameReserved', (name) ->
  # Reserve profile names beginning with double-underscore.
  (name.charCodeAt(0) == charCodeUnderscore and
  name.charCodeAt(1) == charCodeUnderscore)

angular.module('proxy').config ($stateProvider, $urlRouterProvider,
$httpProvider, $animateProvider, $compileProvider) ->
  $compileProvider.aHrefSanitizationWhitelist(
    /^\s*(https?|ftp|mailto|chrome-extension|moz-extension):/)
  $compileProvider.imgSrcSanitizationWhitelist(
    /^\s*(https?|local|data|chrome-extension|moz-extension):/)
  $animateProvider.classNameFilter(/angular-animate/)

  $urlRouterProvider.otherwise '/profiles'
  
  $urlRouterProvider.otherwise ($injector, $location) ->
    if $location.path() == ''
      $injector.get('proxyTarget').lastUrl() || '/profiles'
    else
      '/profiles'
  
  $stateProvider
    .state('default',
      url: '/profiles'
      templateUrl: 'partials/profile_list.html'
    ).state('ui',
      url: '/ui'
      templateUrl: 'partials/ui.html'
    ).state('general',
      url: '/general'
      templateUrl: 'partials/general.html'
    ).state('io',
      url: '/io'
      templateUrl: 'partials/io.html'
      controller: 'IoCtrl'
    ).state('builtin',
      url: '/builtin'
      templateUrl: 'partials/builtin.html'
      controller: 'BuiltinCtrl'
    ).state('theme',
      url: '/theme'
      templateUrl: 'partials/theme.html'
    ).state('profile',
      url: '/profile/*name'
      templateUrl: 'partials/profile.html'
      controller: 'ProfileCtrl'
    ).state('about',
      url: '/about'
      templateUrl: 'partials/about.html'
      controller: 'AboutCtrl'
    )

angular.module('proxy').factory '$exceptionHandler', ($log) ->
  return (exception, cause) ->
    return if exception.message == 'transition aborted'
    return if exception.message == 'transition superseded'
    return if exception.message == 'transition prevented'
    return if exception.message == 'transition failed'
    $log.error(exception, cause)

angular.module('proxy').factory 'proxyDebug', ($window, $rootScope,
$injector) ->
  proxyDebug = $window.OmegaDebug ? {}

  proxyDebug.downloadLog ?= ->
    downloadFile = $injector.get('downloadFile') ? saveAs
    blob = new Blob [localStorage['log']], {type: "text/plain;charset=utf-8"}
    downloadFile(blob, "网罗代理Log_#{Date.now()}.txt")

  proxyDebug.reportIssue ?= ->
    $window.open(
      'https://github.com/rossi023/SwitchyOmega/issues/new?title=&body=')
    return

  proxyDebug.resetOptions ?= ->
    $rootScope.resetOptions()

  proxyDebug

angular.module('proxy').factory 'downloadFile', ->
  return (blob, filename) ->
    noAutoBom = true
    saveAs(blob, filename, noAutoBom)
