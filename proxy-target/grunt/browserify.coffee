module.exports =
  index:
    files:
      'index.js': 'index.coffee'
    options:
      transform: ['coffeeify']
      exclude: ['bluebird', 'jsondiffpatch', 'proxy-pac']
      browserifyOptions:
        extensions: '.coffee'
        builtins: []
        standalone: 'index.coffee'
        debug: true
  browser:
    files:
      'proxy_target.min.js': 'index.coffee'
    options:
      alias: [
        './index.coffee:ProxyTarget'
      ]
      transform: ['coffeeify']
      plugin:
        if process.env.BUILD == 'release'
          [['minifyify', {map: false}]]
        else
          []
      browserifyOptions:
        extensions: '.coffee'
        standalone: 'ProxyTarget'
