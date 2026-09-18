module.exports =
  web:
    expand: true
    cwd: 'src/coffee'
    src: ['**/*.coffee']
    dest: 'build/js/'
    ext: '.js'
  web_proxy:
    files:
      'build/js/proxy.js': 'src/proxy/**/*.coffee'
