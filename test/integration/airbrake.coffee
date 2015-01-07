Hapi = require 'hapi'
should = require('chai').should()
Airbrake = require '../../lib'
AirbrakeInternal = require '../../lib/airbrake'
Info = require '../airbrake_info.json'

describe 'Airbrake Hapi', ->

  it 'should correctly send', (done)->
      error = new Error('It Broke Here')
      hapiRequest =
        url:
          path: '/testing/test/t'

      options =
        id: Info.id
        key: Info.key
        name: 'TEST APP'
        notifierURL: 'https://github.com/Wayfarer247/airbrake-hapi'
        version: '1.x'

      airbrake = new AirbrakeInternal({on: (->)}, options)
      airbrake.environment = 'production'
      airbrake.start ->
        airbrake.notify(error, hapiRequest).then (result)->
          result.id.should.be.ok
          result.url.should.contain 'https://airbrake.io/locate'
          done()

  it 'should error without a proper config', (done)->
    error = new Error('It Broke Here')
    hapiRequest =
      url:
        path: '/testing/test/t'

    options =
      id: Info.id
      key: Info.key

    airbrake = new AirbrakeInternal({on: (->)}, {})
    airbrake.environment = 'production'
    airbrake.start ->
      airbrake.notify(error, hapiRequest).fail (err)->
        err.message.should.equal 'options.uri is a required argument'
        done()

  it 'should fail to load the plugin with no id/key given', (done)->
    server = new Hapi.Server()
    server.connection()
    server.register register: Airbrake, (err)->
      err.message.should.equal 'No Project ID or API Key was given!'
      done()

  it 'should load the plugin with the id and key', (done)->
    server = new Hapi.Server()
    server.connection()
    server.register {register: Airbrake, options: {id: '1', key: '2'}}, (err)->
      should.not.exist err
      done()

  it 'should notify when an error occurs', (done)->
    @timeout 5000
    server = new Hapi.Server()

    handler = (req, reply)->
      throw new Error('BROKEN!')
      reply()

    server.connection()
    server.route(method: 'GET', path: '/', handler: handler)

    options =
      id: Info.id
      key: Info.key
      name: 'TEST APP'
      notifierURL: 'https://github.com/Wayfarer247/airbrake-hapi'

    server.register {register: Airbrake, options: options}, (err)->
      should.not.exist err

      server.inject {method: 'GET', url: '/'}, (res)->
        res.statusCode.should.equal 500
        setTimeout(->
          done()
        , 2000)
