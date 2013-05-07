{spawn, exec} = require 'child_process'

dest = 'build'
src = 'src'

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'Build the project', ->
  spawn 'rm', ['-r', dest]
  spawn 'cp', ['-r', src, dest]
  coffee = spawn 'coffee', ['-j', dest + '/scripts/background.js', '-c', src + '/scripts/background/']
  coffee = spawn 'coffee', ['-j', dest + '/scripts/views.js', '-c', src + '/scripts/views/']
  coffee.stdout.on 'data', (data) -> console.log data.toString().trim()
  spawn 'find', [dest, '-type', 'f', '-name', '*.coffee', '-exec', 'rm', '-f', '{}', '\;']
