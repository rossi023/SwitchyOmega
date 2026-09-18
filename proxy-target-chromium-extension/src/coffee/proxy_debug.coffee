
logStore = idbKeyval.createStore('log-store', 'log-store')
syncStore = idbKeyval.createStore('sync-store', 'sync')

waitTimeFn = (timeout = 1000) ->
  return new Promise((resolve, reject) ->
    setTimeout( ->
      resolve()
    , timeout)
  )

window.ProxyDebug =
  getProjectVersion: ->
    chrome.runtime.getManifest().version
  getExtensionVersion: ->
    chrome.runtime.getManifest().version
  downloadLog: ->
    idbKeyval.entries(logStore).then((entries) ->
      zip = new JSZip()
      zipFolder = zip.folder('网罗代理')
      entries.forEach((entry) ->
        if entry[0] != 'lastError'
          zipFolder.file(entry[1].date + '.log', entry[1].val)
      )
      return zip.generateAsync({
        compression: "DEFLATE",
        compressionOptions: {
          level: 9
        },
        type: 'blob'
      })
    ).then((blob) ->
      filename = "网罗代理Log_#{Date.now()}.zip"
      saveAs(blob, filename)
    )
  resetOptions: ->
    chrome.runtime.sendMessage({
      method: 'resetAllOptions'
    }, (response) ->
      # firefox still use localStorage
      localStorage.clear()
      # as storage watch value changed
      # and background localStorage state delay saved
      # this must after storage and wait 2 seconds
      Promise.all([
        idbKeyval.clear(logStore),
        idbKeyval.clear(syncStore),
        waitTimeFn(2000)
      ]).then( ->
        idbKeyval.clear()
      ).then( ->
        # Prevent options loading from sync storage after reload.
        #localStorage['proxy.local.syncOptions'] = '"conflict"'
        chrome.runtime.reload()
      )
    )
  reportIssue: ->
    idbKeyval.get('lastError', logStore).then((lastError) ->
      url = 'https://github.com/issues/new?title=&body='
      finalUrl = url
      try
        projectVersion = ProxyDebug.getProjectVersion()
        extensionVersion = ProxyDebug.getExtensionVersion()
        env =
          extensionVersion: extensionVersion
          projectVersion: extensionVersion
          userAgent: navigator.userAgent
        body = chrome.i18n.getMessage('popup_issueTemplate', [
          env.projectVersion, env.userAgent
        ])
        body ||= """
          \n\n
          <!-- Please write your comment ABOVE this line. -->
          网罗代理 #{env.projectVersion}
          #{env.userAgent}
        """
        finalUrl = url + encodeURIComponent(body)
        err = lastError or ''
        if err
          body += "\n```\n#{err}\n```"
          finalUrl = (url + encodeURIComponent(body)).substr(0, 2000)

      chrome.tabs.create(url: finalUrl)
    )
