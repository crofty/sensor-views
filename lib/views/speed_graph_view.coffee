require('sensor-views/libs/d3')
require('sensor-views/libs/d3.layout')

Sensor.Views.SpeedGraphView = SC.View.extend
  classNames: 'chart'
  w: 785
  h: 96
  didInsertElement: ->
    @_super()
    parentDivId = @getPath('parentView.elementId')
    datetime = @getPath('content.messages.firstObject.datetime')
    midnight = datetime.adjust({hour:0, minute:0, second: 0}).get('milliseconds')
    # Probably don't want all the datapoints, just the first and last of a journey and then a selection of the ones inbetween
    journeys = @getPath('content.journeys.content')
    # data = @getPath('content.messages').map (m) ->
    #   {x: m.getPath('datetime.milliseconds') - midnight, y:parseInt(m.get('speed'))}
    messageToData = (m) ->
      {x: m.getPath('datetime.milliseconds') - midnight, y:parseInt(m.get('speed'))}

    maxSpeed = d3.max @getPath('content.messages').map (x) -> parseInt x.get('speed')
    w = @get('w')
    h = @get('h')
    mx = 1000*60*60*24
    my = maxSpeed
    margin = 0
    y = d3.scale.linear().domain([0, maxSpeed]).range([0 + margin, h - margin])
    x = d3.scale.linear().domain([0, mx]).range([0 + margin, w - margin])

    vis = d3.select("##{parentDivId} .chart")
       .append("svg:svg")
       .attr("width", w)
       .attr("height", h)

    # Group for putting the hoverable areas on
    areaGroup = vis.append("svg:g").attr("transform", "translate(0, #{h})")
    # Group for putting the graph lines on
    g = vis.append("svg:g").attr("transform", "translate(0, #{h})")

    line = d3.svg.line()
        .x( (d) -> x(d.x) )
        .y( (d) -> -1 * y(d.y) )

    # Add a base line along bottom of graph
    g.append("svg:line")
        .attr("x1", x(0))
        .attr("y1", -1 * y(0))
        .attr("x2", x(mx))
        .attr("y2", -1 * y(0))
        .attr("stroke", "#e6e8e9")
        .attr("opacity", 0.5)

    # Used to generate the hoverable areas of the graph
    area = d3.svg.area()
      .x( (d) -> x(d) )
      .y0( -> -1 * y(0) )
      .y1( -> -1 * y(maxSpeed) )

    # This just wraps some of the d3 stuff up into a sproutcore object
    # so that we can use bindings and change the path properties when 
    # things change
    Sensor.SVGPath = SC.Object.extend
      init: ->
        @_super()
        obj = @get('obj') # Either a stop or a journey
        data = @get('data')
        elem = g
          .append("svg:path")
          .attr('class', obj.get('id'))
          .attr("d", line(@get('data')))
          .on('mouseover', -> obj.set('hover',true) )
          .on('mouseout',  -> obj.set('hover',false) )
        areaGroup
          .append("svg:path")
          .attr("d", area([data.getPath('firstObject.x'),data.getPath('lastObject.x')]))
          .style('fill','transparent')
          .style('stroke','none')
          .attr('class', "area-#{obj.get('id')}")
          .on('mouseover', -> obj.set('hover',true) )
          .on('mouseout',  -> obj.set('hover',false) )
        @set('d3elem', d3.select("path.#{obj.get('id')}"))
        @set('area-d3elem', d3.select("path.area-#{obj.get('id')}"))
      _hoverDidChange: ( ->
        hoverColor = '#cc0000'
        if @getPath('obj.hover')
          @get('d3elem')
            .style('stroke',hoverColor)
            .style('fill',hoverColor)
          @get('area-d3elem')
            .style('fill',hoverColor)
            .style('opacity','0.1')
        else
          @get('area-d3elem')
            .style('fill','transparent')
          @get('d3elem')
            .style('stroke','steelblue')
            .style('fill','steelblue')
      ).observes('obj.hover')

    # Add a line for the start location
    s = @getPath('content.startLocation')
    data = []
    data.push
      x: 0
      y: 0
    data.push
      x: (s.getPath('leaveTime.milliseconds') || SC.DateTime.create().get('milliseconds')) - midnight
      y: 0
    Sensor.SVGPath.create(data: data, obj: s)

    # Add a line for each of the stops
    @getPath('content.stops').forEach (s) ->
      data = []
      data.push
        x: s.getPath('arriveTime.milliseconds') - midnight
        y: 0
      data.push
        x: (s.getPath('leaveTime.milliseconds') || SC.DateTime.create().get('milliseconds')) - midnight
        y: 0
      Sensor.SVGPath.create(data: data, obj: s)

    # Add a line for each of the journeys
    journeys.forEach (j) ->
      data = []
      data.push
        x: j.getPath('startTime.milliseconds') - midnight
        y: 0
      # Include one data point for each message
      j.getPath('messages').forEach (m) -> data.push messageToData(m)
      data.push
        x: j.getPath('endTime.milliseconds') - midnight
        y: 0
      Sensor.SVGPath.create(data: data, obj: j)

