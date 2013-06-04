#-------------------------------------------------------------------------------------------------------------
#
# Description   : Simple Utility-Script which lets you require other Coffee-Files in a CoffeeScript
#				  and manage your dependencies
# Author        : Bastian Behrens, 2012
# Author        : Kevin van der Vlist, 2013
#
# Requirements  : needs node.js, CoffeeScript and underscore.js installed
# Usage         : runs from your command-line with the options (-I) for Include-Directories and (-F) for all
#                 files to be included
# Example       : $ coffee simple-coffee-dependencies.coffee -I <this/is/a/folder/> -F <file.coffee>
#
#-------------------------------------------------------------------------------------------------------------


# imports
util          = require 'util'
fs            = require 'fs'
path          = require 'path'
_             = require 'underscore'

# find all dependencies in a given file
# if a dependency-file could not be found,
# a warning is written as comment to the output
findDependencies = (file) ->
  dependencies = []
  dependencyRegex = /#=\s*require\s+([A-Za-z_$-][A-Za-z0-9_$-/]*)/g

  txt = readFileContents file
  while (result = dependencyRegex.exec(txt)) != null
    resolved = false
    for dir in includeDirs
      if fs.existsSync(dir + result[1]) and not _.include(dependencies, dir + result[1])
        dependencies.push(dir + result[1])
        resolved = true
    if not resolved
      util.puts "#WARNING: dependency '" + result[1] + "' in file '" + file + "' could not be resolved"
  return dependencies

# resolving dependencies for one file
# this is done recursive. finally it is
# ensured, that every dependency is only
# included once
resolveDependencies = (file) ->
  deps = findDependencies(file)
  result = []
  for dep in deps
    result = result.concat(resolveDependencies dep)
    result.push dep
  _.uniq(result)

# readsContent from the specified file
readFileContents = (file) ->
  fs.readFileSync(file).toString()

# just to make sure, that includedDirectory-String has a trailing slash
ensureDirHasTrailingSlash = (dir) ->
  if dir.charAt(dir.length-1) is '/' then dir else dir + '/'

# run function to start the concatenation-process
# first all dependencies for each given source-file
# are found. double entries are removed to ensure that
# every dependency is only included once. if more than
# one source-file is given, same is done here. if a needed
# dependency is already included above, it will not be included
# a second time
run = (sourceFiles, includeDirs) ->
  dependencies = []
  allDependencies = []
  output = []
  for file in sourceFiles
    dependencies = resolveDependencies file
    dependencies = _.without(dependencies, allDependencies)
    allDependencies = allDependencies.concat(dependencies)
    for dependency in dependencies
      output.push(readFileContents dependency, true)
    output.push(readFileContents file, true)
  util.puts output.join('\n\n').replace(/#=\s*require\s+([A-Za-z_$-][A-Za-z0-9_$-/]*)/g, '')

# we need to evaluate the passed arguments and find
# all sourceFiles + all directories where files could be
# included. sourceFiles must be .coffee files, all files
# and directories are checked if they exist!
#
# options are:
# -F  => file to include
# -I  => directory to include
sourceFiles   = []
includeDirs   = []
args = process.argv.slice(2)
includeDirs.push ""
_.each args, (arg, index) ->
  sourceFiles.push(args[index + 1]) if arg is "-F" and
    /\.coffee$/.test(args[index + 1]) and
    fs.existsSync(args[index + 1])
  includeDirs.push(ensureDirHasTrailingSlash(args[index + 1])) if arg is "-I" and
    fs.existsSync(args[index + 1])

# check if at least 1 source + 1 directory is defined
# if so, run the concatenation, if not log an error message
if _.size(sourceFiles) > 0 and _.size(includeDirs) > 0
  run sourceFiles, includeDirs
else
  util.puts "ERROR: You have specified #{_.size sourceFiles} valid Coffee SourceFiles " +
            "and #{_.size includeDirs} IncludeDirectories. " +
            "You need to specify at least 1 valid Coffee SourceFile (-F)"
