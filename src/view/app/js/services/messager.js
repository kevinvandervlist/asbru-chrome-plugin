'use strict';

/**
 * 
 */
dbg.factory('messager', ["PortName", function(portName) {
  var seq = 0;
  var cbs = [];

  var port = chrome.runtime.connect({
    name: portName
  });
  
  port.onMessage.addListener(function(message) {
    // Check for a callback
    if(cbs[message.request_seq] !== undefined) {
      cbs[message.request_seq](message);
    } else {
      console.log("[services/messager.js] Received a message without available callback:");
      console.log(message);
    }
  });

	return {
    /**
     * Send a specific message to the backend.
     */
		sendMessage: function (command, message, callback) {
      // Setup callback for this request.
      if(callback === undefined) {
        cbs[seq] = function(){};
      } else {
        cbs[seq] = callback;
      }
      console.log(cbs);
      // Check if we have a message body
      if(message === undefined) {
        message = {};
      }

      // Construct the actual message
      message.type = command;
      message.seq = seq++;

      // Send the message
			port.postMessage(message);
		},
	};
}]);

    // Messaging.prototype._MessageEventCallback = function(message) {
    //   var error;

    //   this.logger.log("Received: " + message.type);
    //   if (message.type == null) {
    //     this.logger.log("Message cannot be understood...");
    //     console.log(message);
    //     void 0;
    //   }
    //   try {
    //     return this.lookup_table[message.type](message);
    //   } catch (_error) {
    //     error = _error;
    //     console.log(error);
    //     this.logger.log("" + message.type + ": unsupported.");
    //     console.log("" + message.type + ": unsupported.");
    //     console.log(message);
    //     return this.lookup_table[message.type](message);
    //   }
    // };
