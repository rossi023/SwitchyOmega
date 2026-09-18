module.exports =
  web:
    expand: true
    cwd: '../omega-web/build'
    src: ['**/*']
    dest: 'build/'
  target:
    files:
      'build/js/proxy_target.min.js':
        'node_modules/proxy-target/proxy_target.min.js'
  target_self:
    src: 'proxy_target_chromium_extension.min.js'
    dest: 'build/js/'
  target_popup:
    expand: true
    cwd: 'src/js'
    src: 'proxy_target_popup.js'
    dest: 'build/js/'
  overlay:
    expand: true
    cwd: 'overlay'
    src: ['**/*']
    dest: 'build/'
  docs:
    expand: true
    cwd: '..'
    src: ['COPYING', 'AUTHORS']
    dest: 'build/'
