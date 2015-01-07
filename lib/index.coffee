#
# Requires
#
Airbrake = require('./airbrake');

#
# Hapi Plugin Interface
#
exports.register = (server, options, next)->
  airbrake = new Airbrake(server, options)
  airbrake.start(next)

#
# Attributes for the plugin
#
exports.register.attributes =
  pkg: require('../package.json')
