module.exports = (grunt) ->
  submodules = ['proxy-pac', 'proxy-target', 'proxy-web', 'proxy-target-*']
  hubConfig =
    all:
      options:
        concurrent: Infinity
      src: "../*/Gruntfile.*"
  for module in submodules
    hubConfig[module] =
      src: "../#{module}/Gruntfile.*"

  hubAll = (task) -> "hub:#{module}:#{task}" for module in submodules

  grunt.initConfig {
    hub: hubConfig
  }

  grunt.loadNpmTasks 'grunt-hub'

  grunt.registerTask 'default', hubAll('default')
  grunt.registerTask 'test', hubAll('test')
  grunt.registerTask 'watch', ['hub:all:watch']
