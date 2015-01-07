'use strict'

#
# Requires
#
Q = require 'q'
os = require 'os'
path = require 'path'
util = require 'util'
Request = require 'request'
stacktrace = require 'stack-trace'
exec = Q.nfbind(require('child_process').exec)

#
# The object which handles the responding to events
class Airbrake

  constructor: (server, options = {})->
    @id = options.id
    @key = options.key
    @version = options.version
    @name = options.name
    @notifierURL = options.notifierURL
    @blacklist = [
      'dev'
      'development'
    ]
    @context(options)

    server.on 'request-error', (request, err)=>
      @notify(err, request)

  start: (next)->
    return next(Error('No Project ID or API Key was given!')) unless @id and @key
    @url = "https://airbrake.io/api/v3/projects/#{@id}/notices?key=#{@key}"

    # Uses Q's .spread to only get the stdout. stderr is passed in as the
    # second parameter, but we don't care about it. Also, if this fails
    # we don't care, because we default to whatever version they pass in.
    @gitVersion().spread (version)=>
      @version = version.replace(/\n/gm, '') if version
    .finally ->
      next()

  gitVersion: ->
    exec('git rev-parse HEAD')

  notify: (err, request)->
    return if @blacklist.indexOf(@environment) > -1

    error = err
    if typeof err is 'object'
      error = err.message

    type = err.type or 'Error'
    message = err.message
    stack = stacktrace.parse(err)
    backtrace = stack.map (s)->
      file: s.getFileName()
      line: s.getLineNumber()
      function: s.getFunctionName() or s.getMethodName()

    json = @buildJSON
      url: request?.url?.path
      error:
        type: type
        message: message
        backtrace: backtrace

    deferred = Q.defer()
    Request.post {url: @url, json: json}, (e, r, body)->
      deferred.reject(e) if e
      deferred.reject() unless body
      deferred.resolve body
    deferred.promise

  context: (options = {})->
    @os = "#{os.hostname()} #{os.type()} #{os.platform()} #{os.arch()} #{os.release()}"
    @language = "Node #{process.version}"
    @environment =
      options.environment or
      options.env or
      process.env.NODE_ENV or
      process.env.ENV or
      'development'
    @rootDirectory = path.dirname require.main.filename

  buildJSON: (data)->
    notifier:
      name: @name
      version: @version
      url: @notifierURL
    errors: [data.error]
    context:
      os: @os
      language: @language
      url: data.url
      environment: @environment
      rootDirectory: @rootDirectory
      version: @version

module.exports = Airbrake
