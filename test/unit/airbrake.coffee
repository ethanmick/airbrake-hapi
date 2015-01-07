should = require('chai').should()
Airbrake = require '../../lib/airbrake'
Info = require '../airbrake_info.json'

describe 'Airbrake', ->

  it 'should exist', ->
    should.exist Airbrake

  it 'should be creatable', ->
    server = on: ->
    airbrake = new Airbrake(server)
    should.exist airbrake

  describe 'creating', ->

    it 'should set the properties', ->
      airbrake = new Airbrake(on: (->), {
        id: '1'
        key: '2'
        version: '0.0'
        name: 'testing'
      })
      airbrake.id.should.equal '1'
      airbrake.key.should.equal '2'
      airbrake.version.should.equal '0.0'
      airbrake.name.should.equal 'testing'
      airbrake.os.should.be.ok
      airbrake.language.should.contain 'Node'
      airbrake.environment.should.be.ok
      airbrake.rootDirectory.should.be.ok

    it 'should get the git version if in git', (done)->
      airbrake = new Airbrake(on: (->), {
        id: '1'
        key: '2'
      })
      airbrake.start ->
        airbrake.version.should.have.length 40
        airbrake.version.should.be.ok
        done()

  describe 'An Airbrake instance', ->

    it 'should fail to start with no id/key', (done)->
      airbrake = new Airbrake(on: ->)
      airbrake.start (err)->
        err.message.should.equal 'No Project ID or API Key was given!'
        done()

    it 'should not crash when getting context', ->
      airbrake = new Airbrake(on: (->), config: Info)
      airbrake.os = undefined
      airbrake.environment = undefined
      airbrake.language = undefined
      airbrake.rootDirectory = undefined
      airbrake.context()
      airbrake.os.should.be.ok
      airbrake.language.should.be.ok
      airbrake.environment.should.be.ok
      airbrake.rootDirectory.should.be.ok

    it 'should return nil when in development', ->
      airbrake = new Airbrake(on: (->), config: Info)
      error = new Error('It Broke Here')

      hapiRequest =
        url:
          path: '/testing/test/t'

      result = airbrake.notify(error, hapiRequest)
      should.not.exist result
