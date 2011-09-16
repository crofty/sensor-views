Sensor.Views.AddressView = SC.View.extend
  init: ->
    @_super()
    Sensor.toGeocode ?= []
  tagName: 'span'
  template: SC.Handlebars.compile "{{content.address}}"
  classNames: 'address'
  addressNeedsGeocoding: (message) ->
    message && message.get('address_type') != 'google'
  didInsertElement: ->
    @_super()
    # This address is being displayed to the user and therefore, if this address has
    # not been google geocoded, then add it to the geocoding queue.
    message = @get('content')
    if @addressNeedsGeocoding(message)
      Sensor.toGeocode.push message
