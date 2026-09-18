ProxyTarget = require('proxy-target')
ProxyPac = ProxyTarget.ProxyPac
Promise = ProxyTarget.Promise
chromeApiPromisify = require('../chrome_api').chromeApiPromisify
ProxyImpl = require('./proxy_impl')

class SettingsProxyImpl extends ProxyImpl
  @isSupported: -> chrome?.proxy?.settings?
  features: ['fullUrlHttp', 'pacScript', 'watchProxyChange']
  applyProfile: (profile, meta, options) ->
    meta ?= profile
    if profile.profileType == 'SystemProfile'
      # Clear proxy settings, returning proxy control to Chromium.
      return chromeApiPromisify(chrome.proxy.settings, 'clear')({}).then =>
        chrome.proxy.settings.get {}, @_proxyChangeListener
        return
    config = {}
    if profile.profileType == 'DirectProfile'
      config['mode'] = 'direct'
    else if profile.profileType == 'PacProfile'
      config['mode'] = 'pac_script'

      config['pacScript'] =
        if !profile.pacScript || ProxyPac.Profiles.isFileUrl(profile.pacUrl)
          url: profile.pacUrl
          mandatory: true
        else
          data: ProxyPac.PacGenerator.ascii(profile.pacScript)
          mandatory: true
    else if profile.profileType == 'FixedProfile'
      config = @_fixedProfileConfig(profile)
    else
      config['mode'] = 'pac_script'
      config['pacScript'] =
        mandatory: true
        data: @getProfilePacScript(profile, meta, options)
    return @setProxyAuth(profile, options).then(->
      return chromeApiPromisify(chrome.proxy.settings, 'set')({value: config})
    ).then(=>
      chrome.proxy.settings.get {}, @_proxyChangeListener
      return
    )
  _fixedProfileConfig: (profile) ->
    config = {}
    config['mode'] = 'fixed_servers'
    rules = {}
    protocols = ['proxyForHttp', 'proxyForHttps', 'proxyForFtp']
    protocolProxySet = false
    for protocol in protocols when profile[protocol]?
      rules[protocol] = profile[protocol]
      protocolProxySet = true

    if profile.fallbackProxy
      if profile.fallbackProxy.scheme == 'http'
        # Chromium does not allow HTTP proxies in 'fallbackProxy'.
        if not protocolProxySet
          # Use 'singleProxy' if no proxy is configured for other protocols.
          rules['singleProxy'] = profile.fallbackProxy
        else
          # Try to set the proxies of all possible protocols.
          for protocol in protocols
            rules[protocol] ?= JSON.parse(JSON.stringify(profile.fallbackProxy))
      else
        rules['fallbackProxy'] = profile.fallbackProxy
    else if not protocolProxySet
      config['mode'] = 'direct'

    if config['mode'] != 'direct'
      rules['bypassList'] = bypassList = []
      for condition in profile.bypassList
        bypassList.push(@_formatBypassItem(condition))
      config['rules'] = rules
    return config
  _formatBypassItem: (condition) ->
    str = ProxyPac.Conditions.str(condition)
    i = str.indexOf(' ')
    return str.substr(i + 1)

  _proxyChangeWatchers: null
  _proxyChangeListener: (details) ->
    for watcher in (@_proxyChangeWatchers ? [])
      watcher(details)
  watchProxyChange: (callback) ->
    if not @_proxyChangeWatchers?
      @_proxyChangeWatchers = []
      if chrome?.proxy?.settings?.onChange?
        chrome.proxy.settings.onChange.addListener(
          @_proxyChangeListener.bind(this))
    @_proxyChangeWatchers.push(callback)
    return
  parseExternalProfile: (details, options) ->
    if details.name
      return details
    switch details.value.mode
      when 'system'
        ProxyPac.Profiles.byName('system')
      when 'direct'
        ProxyPac.Profiles.byName('direct')
      when 'auto_detect'
        ProxyPac.Profiles.create({
          profileType: 'PacProfile'
          name: ''
          pacUrl: 'http://wpad/wpad.dat'
        })
      when 'pac_script'
        url = details.value.pacScript.url
        if url
          profile = null
          ProxyPac.Profiles.each options, (key, p) ->
            if p.profileType == 'PacProfile' and p.pacUrl == url
              profile = p
          profile ? ProxyPac.Profiles.create({
            profileType: 'PacProfile'
            name: ''
            pacUrl: url
          })
        else do ->
          profile = null
          script = details.value.pacScript.data
          ProxyPac.Profiles.each options, (key, p) ->
            if p.profileType == 'PacProfile' and p.pacScript == script
              profile = p
          return profile if profile
          # Try to parse the prefix used by this class.
          script = script.trim()
          magic = '/*ProxyProfile*'
          if script.substr(0, magic.length) == magic
            end = script.indexOf('*/')
            if end > 0
              i = magic.length
              tokens = script.substring(magic.length, end).split('*')
              [profileName, revision] = tokens
              try
                profileName = JSON.parse(profileName)
              catch _
                profileName = null
              if profileName and revision
                profile = ProxyPac.Profiles.byName(profileName, options)
                if ProxyPac.Revision.compare(profile.revision, revision) == 0
                  return profile
          return ProxyPac.Profiles.create({
            profileType: 'PacProfile'
            name: ''
            pacScript: script
          })
      when 'fixed_servers'
        props = ['proxyForHttp', 'proxyForHttps', 'proxyForFtp',
          'fallbackProxy', 'singleProxy']
        proxies = {}
        for prop in props
          result = ProxyPac.Profiles.pacResult(details.value.rules[prop])
          if prop == 'singleProxy' and details.value.rules[prop]?
            proxies['fallbackProxy'] = result
          else
            proxies[prop] = result
        bypassSet = {}
        bypassCount = 0
        if details.value.rules.bypassList
          for pattern in details.value.rules.bypassList
            bypassSet[pattern] = true
            bypassCount++
        if bypassSet['<local>']
          for host in ProxyPac.Conditions.localHosts when bypassSet[host]
            delete bypassSet[host]
            bypassCount--
        profile = null
        ProxyPac.Profiles.each options, (key, p) =>
          return if p.profileType != 'FixedProfile'
          return if p.bypassList.length != bypassCount
          for condition in p.bypassList
            return unless bypassSet[condition.pattern]
          rules = @_fixedProfileConfig(p).rules
          if rules['singleProxy']
            rules['fallbackProxy'] = rules['singleProxy']
            delete rules['singleProxy']
          return unless rules?
          for prop in props when rules[prop] or proxies[prop]
            if ProxyPac.Profiles.pacResult(rules[prop]) != proxies[prop]
              return
          profile = p
        if profile
          profile
        else
          profile = ProxyPac.Profiles.create({
            profileType: 'FixedProfile'
            name: ''
          })
          for prop in props when details.value.rules[prop]
            if prop == 'singleProxy'
              profile['fallbackProxy'] = details.value.rules[prop]
            else
              profile[prop] = details.value.rules[prop]
          profile.bypassList =
            for own pattern of bypassSet
              {conditionType: 'BypassCondition', pattern: pattern}
          profile

module.exports = SettingsProxyImpl
