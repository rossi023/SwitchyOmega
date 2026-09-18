angular.module('proxy').controller 'ProfileCtrl', ($scope, $stateParams,
  $location, $rootScope, $timeout, $state, $modal, profileColorPalette,
  getAttachedName, getParentName, getVirtualTarget) ->
  profileTemplates =
    'FixedProfile': 'profile_fixed.html'
    'PacProfile': 'profile_pac.html'
    'VirtualProfile': 'profile_virtual.html'
    'SwitchProfile': 'profile_switch.html'
    'RuleListProfile': 'profile_rule_list.html'

  loadProfile = ->
    name = $state.params.name
    return if not name or not $scope.options
    profile = $scope.options['+' + name]
    return if not profile
    if OmegaPac.Profiles.formatByType[profile.profileType]
      profile.format = OmegaPac.Profiles.formatByType[profile.profileType]
      profile.profileType = 'RuleListProfile'
    $scope.profile = profile
    type = $scope.profile.profileType
    templ = profileTemplates[type] ? 'profile_unsupported.html'
    $scope.profileTemplate = 'partials/' + templ
    $scope.scriptable = true
    $scope.watchAndUpdateRevision 'profile'

  $scope.spectrumOptions =
    localStorageKey: 'spectrum.profileColor'
    palette: profileColorPalette
    preferredFormat: 'hex'
    showButtons: false
    showInitial: true
    showInput: true
    showPalette: true
    showAlpha: true
    showSelectionPalette: true
    maxSelectionSize: 5

  $scope.getProfileColor = ->
    color = undefined
    profile = $scope.profile
    while profile
      color = profile.color
      profile = getVirtualTarget(profile, $scope.options)
    color

  $scope.deleteProfile = ->
    profileName = $scope.profile.name
    refs = OmegaPac.Profiles.referencedBySet(profileName, $rootScope.options)

    scope = $rootScope.$new('isolate')
    scope.profile = $scope.profile
    scope.dispNameFilter = $scope.dispNameFilter
    scope.options = $scope.options

    if Object.keys(refs).length > 0
      refSet = {}
      for own key, pname of refs
        parent = getParentName(pname)
        if parent
          key = OmegaPac.Profiles.nameAsKey(parent)
          pname = parent
        refSet[key] = pname

      refProfiles = []
      for own key of refSet
        refProfiles.push(OmegaPac.Profiles.byKey(key, $rootScope.options))
      scope.refs = refProfiles
      $modal.open(
        templateUrl: 'partials/cannot_delete_profile.html'
        scope: scope
      )
      return
    else
      $modal.open(
        templateUrl: 'partials/delete_profile.html'
        scope: scope
      ).result.then ->
        attachedName = getAttachedName(profileName)
        delete $rootScope.options[OmegaPac.Profiles.nameAsKey(attachedName)]
        delete $rootScope.options[OmegaPac.Profiles.nameAsKey(profileName)]
        if $rootScope.options['-startupProfileName'] == profileName
          $rootScope.options['-startupProfileName'] = ""
        quickSwitch = $rootScope.options['-quickSwitchProfiles']
        for i in [0...quickSwitch.length]
          if profileName == quickSwitch[i]
            quickSwitch.splice i, 1
            break
        $state.go 'default'

  # The watcher should be applied on the calling scope.
  # coffeelint: disable=missing_fat_arrows
  $scope.watchAndUpdateRevision = (expression) ->
    revisionChanged = false
    onChange = (profile, oldProfile) ->
      return profile if profile == oldProfile or not profile or not oldProfile
      if revisionChanged and profile.revision != oldProfile.revision
        revisionChanged = false
      else
        OmegaPac.Profiles.updateRevision(profile)
        revisionChanged = true
    this.$watch expression, onChange, true

  $scope.exportRuleList = null
  $scope.exportRuleListOptions = null
  $scope.setExportRuleListHandler = (exportRuleList, options) ->
    $scope.exportRuleList = exportRuleList
    $scope.exportRuleListOptions = options

  $scope.$on '$stateChangeSuccess', ->
    loadProfile()

  $scope.$watch 'options', ->
    loadProfile() if $scope.options
