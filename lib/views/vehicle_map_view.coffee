Sensor.Views.VehicleMapView = SC.View.extend
  contentBinding: 'parentView.content'
  classNames: 'map-container'
  template: SC.Handlebars.compile '<div class="map"/>'
  didInsertElement: ->
    if @getPath('content.moved')
      map = SM.Map.create
        divId: @$('.map')[0]
        options:
          scrollWheelZoom: false
      @set('map', map)
      @_createJourneysOnMap()
      @_createStartLocationOnMap()
      @_createStopsOnMap()
  _createJourneysOnMap: ( ->
    map = @get('map')
    if map
      # console.log "creating journeys on map"
      journeys = @getPath('content.journeys')
      journeys.forEach (journey) =>
        points = journey.get('messages').map (m) -> [m.get('lat'), m.get('lon')]
        polyline = SM.HoverablePolyline.create
          points: points
          journey: journey
          hoverBinding: 'journey.hover'
        map.addObject(polyline)
      map.fitAllObjects()
  )
  _createStartLocationOnMap: ( ->
    map = @get('map')
    if map
      # console.log "creating start location on map"
      stop = @getPath('content.startLocation')
      marker = SM.HoverableMarker.create
        lat: stop.get('lat')
        lon: stop.get('lon')
        stop: stop
        hoverBinding: 'stop.hover'
      map.addObject(marker)
      map.fitAllObjects()
  )
  _createStopsOnMap: ( ->
    map = @get('map')
    if map
      # console.log "creating stops on map"
      stops = @getPath('content.stops')
      stops.forEach (stop) =>
        marker = SM.HoverableMarker.create
          lat: stop.get('lat')
          lon: stop.get('lon')
          stop: stop
          hoverBinding: 'stop.hover'
        map.addObject(marker)
      map.fitAllObjects()
  )
