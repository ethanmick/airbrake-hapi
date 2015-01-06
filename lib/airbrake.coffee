'use strict'

Q = require 'q'
os = require 'os'
util = require 'util'
Request = require 'request'
stacktrace = require 'stack-trace'
exec = Q.nfbind(require('child_process').exec)

class Airbrake

  setup: (options = {})->
    @baseURL = 'https://airbrake.io/api/v3/projects/%s/notices?key=%s'
    @id = options.id
    @key = options.key
    return unless @id and @key
    @_isReady = yes
    @baseURL = util.format @baseURL, @id, @key

    @version = options.version
    @gitVersion().spread (version)=>
      @version = version if version

    @name = options.name
    @notifierURL = options.notifierURL
    @context(options)
    @

  gitVersion: ->
    exec('git rev-parse HEAD')

  constructor: ->
    @_isReady = no

  notify: (err, request, data = {})->
    return unless @_isReady
    error = err;
    if typeof err is 'object'
      error = err.message

    type = err.type or 'Error'
    message = err.message
    stack = stacktrace.parse(err)
    backtrace = stack.map (s)->
      file: s.getFileName()
      line: s.getLineNumber()
      function: s.getFunctionName() or s.getMethodName()

    json = @buildJSON(
      data: data
      url: request?.url?.path
      error:
        type: type
        message: message
        backtrace: backtrace
    )

    deferred = Q.defer()
    Request.post {url: @baseURL, json: json}, (e, r, body)->
      deferred.reject(e) if e
      deferred.reject() unless body
      deferred.resolve body

    deferred.promise

  context: (options = {})->
    @os = os.hostname() + ' ' + os.type() + ' ' + os.platform() + ' ' + os.arch() + ' ' + os.release()
    @language = 'Node ' + process.version
    @environment = options.environment or process.env.NODE_ENV or 'development'
    @rootDirectory = __dirname


  buildJSON: (data)->
    return {
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
    }

module.exports = new Airbrake()
