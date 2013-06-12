# HOOCSD plugin
## Building notes
* Files from src/scripts/util/* can be referenced as if placed in the local directory of any sourcefile in the project. 
As an example, see #= require DataStore.coffee from src/scripts/views/data/ViewData.coffee references src/scripts/util/DataStore.coffee.
## Console functions: 
* sendmessage <JSON> (e.g. sendmessage {"type": "foo"})
Send a manually created message to the background process
* r / resume
Resume JavaScript execution on the page.
* p / pause
Pause JavaScript execution on the page.
* breakpointsActive <true | false>
Activate / deactivate all breakpoints

# Code
## node-inspector
Some code is taken from node-inspector. These files can be found in src/scripts/background/debug/node/inspector_utils/
