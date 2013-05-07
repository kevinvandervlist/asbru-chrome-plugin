{spawn, exec} = require 'child_process'

#dest = 'build'
dest = 'build'
scriptname = 'plugin.js'
src = 'src'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'continually build with --watch', ->
  spawn 'rm', ['-r', dest]
  spawn 'cp', ['-r', src, dest]
  #coffee = spawn 'coffee', ['-cw', '-j', dest, 'src']
  coffee = spawn 'coffee', ['-j', dest + '/' + scriptname, '-w', '-c', src]
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  spawn 'find', [dest, '-type', 'f', '-name', '*.coffee', '-exec', 'rm', '-f', '{}', '\;']
