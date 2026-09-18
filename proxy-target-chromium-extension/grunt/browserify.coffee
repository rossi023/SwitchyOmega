path = require('path')
module.exports =
  index:
    files:
      'index.js': 'index.coffee'
    options:
      transform: ['coffeeify']
      exclude: ['bluebird', 'proxy-pac', 'proxy-target']
      browserifyOptions:
        extensions: '.coffee'
        builtins: []
        standalone: 'index.coffee'
        debug: true
  browser:
    files:
      'proxy_target_chromium_extension.min.js': 'index.coffee'
    options:
      alias: [
        './index.coffee:ProxyTargetChromium'
      ]
      transform: ['coffeeify']
      plugin:
        if process.env.BUILD == 'release'
          [['minifyify', {map: false}]]
        else
          []
      browserifyOptions:
        extensions: '.coffee'
        standalone: 'ProxyTargetChromium'
  proxy_webext_proxy_script:
    files:
      'build/js/proxy_webext_proxy_script.min.js':
        'src/js/proxy_webext_proxy_script.js'
    options:
      alias:
        'proxy-pac': 'proxy-pac/proxy_pac.min.js'
      plugin:
        if process.env.BUILD == 'release'
          [['minifyify', {map: false}]]
        else
          []
      browserifyOptions:
        noParse: [require.resolve('proxy-pac/proxy_pac.min.js')]
