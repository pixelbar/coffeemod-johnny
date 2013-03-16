module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      scripts:
        files: 
          grunt.file.expandMapping(['src/**/*.coffee'], 'lib/', 
            rename: (destBase, destPath) ->
              return destBase + destPath.slice(4, destPath.length).replace(/\.coffee$/, '.js')
          )
      main:
        files:
          'blog/scripts/main.js': 'src/main.coffee'

    regarde:
      coffee:
        files: ['src/**/*.coffee']
        tasks: ['coffee']

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-regarde'

  grunt.registerTask 'watch', ['coffee', 'regarde']