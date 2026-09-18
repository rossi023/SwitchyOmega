ProxyTarget = require('proxy-target')
Promise = ProxyTarget.Promise
ProxyAuth = require('./proxy_auth')


# TODO temp profile will always create new cache.
profilePacCache = new Map()

class ProxyImpl
  constructor: (log) ->
    @log = log
  @isSupported: -> false
  applyProfile: (profile, meta) -> Promise.reject()
  watchProxyChange: (callback) -> null
  parseExternalProfile: (details, options) -> null
  _profileNotFound: (name) ->
    @log.error("Profile #{name} not found! Things may go very, very wrong.")
    return ProxyPac.Profiles.create({
      name: name
      profileType: 'VirtualProfile'
      defaultProfileName: 'direct'
    })
  setProxyAuth: (profile, options) ->
    return Promise.try(=>
      @_proxyAuth ?= new ProxyAuth(@log)
      @_proxyAuth.listen()
      referenced_profiles = []
      ref_set = ProxyPac.Profiles.allReferenceSet(profile,
        options, profileNotFound: @_profileNotFound.bind(this))
      for own _, name of ref_set
        profile = ProxyPac.Profiles.byName(name, options)
        if profile
          referenced_profiles.push(profile)
      @_proxyAuth.setProxies(referenced_profiles)
    )
  getProfilePacScript: (profile, meta, options) ->
    meta ?= profile
    referenced_profiles = []
    ref_set = ProxyPac.Profiles.allReferenceSet(profile,
      options, profileNotFound: @_profileNotFound.bind(this))
    for own _, name of ref_set
      _profile = ProxyPac.Profiles.byName(name, options)
      if _profile
        referenced_profiles.push(_profile)
    cachedProfiles = Array.from(profilePacCache.keys())
    allProfiles = Object.values(options)
    cachedProfiles.forEach((cachedProfile) ->
      if allProfiles.indexOf(cachedProfile) < 0
        profilePacCache.delete(cachedProfile)
    )
    profilePac = profilePacCache.get(profile)
    profilePacKey = referenced_profiles.map(
      (_profile) ->
        revision = _profile.revision or 1
        # remote pacScript and rule list use sha256 to  ensue uniqueId
        if ProxyPac.Profiles.updateUrl(_profile) and _profile.sha256
          revision = _profile.sha256
        _profile.name + '_' + revision
    ).join(',')
    if profilePac?[profilePacKey]
      return profilePac[profilePacKey]
    ast = ProxyPac.PacGenerator.script(options, profile,
      profileNotFound: @_profileNotFound.bind(this))
    ast = ProxyPac.PacGenerator.compress(ast)
    script = ProxyPac.PacGenerator.ascii(ast.print_to_string())
    profileName = ProxyPac.PacGenerator.ascii(JSON.stringify(meta.name))
    profileName = profileName.replace(/\*/g, '\\u002a')
    profileName = profileName.replace(/\\/g, '\\u002f')
    prefix = "/*ProxyProfile*#{profileName}*#{meta.revision}*/"
    pacScript = prefix + script
    profilePac = {}
    profilePac[profilePacKey] = pacScript
    profilePacCache.set(profile, profilePac)
    return pacScript

module.exports = ProxyImpl
