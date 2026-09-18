module.exports =
  pac:
    files:
      'build/js/proxy_pac.min.js': 'node_modules/proxy-pac/proxy_pac.min.js'
  lib:
    expand: true
    cwd: 'lib'
    src: ['**/*']
    dest: 'build/lib/'
  img:
    expand: true
    cwd: 'img'
    src: ['**/*']
    dest: 'build/img/'
  popup:
    expand: true
    cwd: 'src/popup'
    src: ['**/*']
    dest: 'build/popup/'
