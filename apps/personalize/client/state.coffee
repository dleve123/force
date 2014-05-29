_         = require 'underscore'
sd        = require('sharify').data
Backbone  = require 'backbone'

_.mixin(require 'underscore.string')

# Mapping between the user attribute, the step, and a predicate
# that should return true if they are "completed"
attributeMap =
  # Set to 1 by default in Gravity
  collector_level:
    value     : 'collect'
    predicate : ->
      @user.get('collector_level') isnt 1 and
      @user.get('collector_level')?
  price_range:
    value     : 'price_range'
    predicate : -> @user.has 'price_range'
  location:
    value     : 'location'
    predicate : -> @user.hasLocation()

module.exports = class PersonalizeState extends Backbone.Model
  defaults:
    levels        : ['Yes, I buy art', 'Interested in starting', 'Just looking and learning']
    current_step  : 'collect'
    current_level : 2 # Interested in starting
    __steps__:
      '3' : ['collect', 'price_range', 'artists', 'location', 'galleries', 'institutions']
      '2' : ['collect', 'categories', 'price_range', 'artists', 'location', 'galleries', 'institutions']
      '1' : ['collect', 'location', 'galleries', 'institutions', 'categories', 'artists']

  initialize: (options = {}) ->
    { @user } = options

    @listenTo this, 'transition:next', @next

    # Figure out the first step and set it
    @set 'current_step', @steps()[0]

    super

  get: (attr) ->
    return @get('__steps__')[@get('current_level')] if attr is 'steps'
    super

  # Steps that are complete at initialization
  #
  # return {Array}
  completedSteps: ->
    @__completedSteps__ ?= _.compact _.map attributeMap, (x) =>
      x.value if x.predicate.call this

  steps: ->
    _.without [@get 'steps'].concat(@completedSteps())...

  currentStepIndex: ->
    _.indexOf @steps(), @get('current_step')

  currentStepLabel: ->
    _.map(@get('current_step').split('_'), _.capitalize).join ' '

  stepDisplay: ->
    "Step #{(@currentStepIndex() + 1)} of #{@steps().length}"

  almostDone: ->
    (@currentStepIndex() + 1) is @steps().length

  next: ->
    if @currentStepIndex() + 1 >= @steps().length
      return @trigger 'done'

    @set 'current_step', @steps()[@currentStepIndex() + 1]
