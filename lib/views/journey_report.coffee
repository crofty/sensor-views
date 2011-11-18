Sensor.Views.JourneyReport = SC.View.extend
  className: 'journeyReport'
  template: SC.Handlebars.compile """
  {{view Sensor.Views.StartLocationItem}}
  {{#collection contentBinding="content.journeys"}}
    {{view Sensor.Views.JourneyListItem}}
    {{#if content.finished}}
      {{view Sensor.Views.StopListItem}}
    {{/if}}
  {{/collection}}
  """

Sensor.Views.StartLocationItem = SC.View.extend
  contentBinding: 'parentView.content.startLocation'
  template: SC.Handlebars.compile """
  <div class="times">{{leaveTime}}</div> {{view Sensor.Views.AddressView contentBinding="content.addressMessage"}}
  """
  classNameBindings: ['content.hover']
  leaveTime: ( ->
    if time = @getPath('content.leaveTime')
      time.toFormattedString('%H:%M')
  ).property('content.leaveTime')
  mouseEnter: -> @setPath('content.hover',true)
  mouseLeave: -> @setPath('content.hover',false)

Sensor.Views.JourneyListItem = SC.View.extend
  contentBinding: 'parentView.content'
  template: SC.Handlebars.compile """
  {{duration}}, {{distance}} miles
  """
  classNames: 'journey'
  distance: ( -> Math.round(@getPath('content.distance')*10)/10).property('content.distance').cacheable()
  classNameBindings: ['content.hover']
  mouseEnter: -> @setPath('content.hover',true)
  mouseLeave: -> @setPath('content.hover',false)
  duration: ( ->
    datetime = SC.DateTime.create(milliseconds: @getPath('content.duration'), timezone: 0)
    datetime.toFormattedString('%h:%M') if datetime
  ).property('content.duration')

Sensor.Views.StopListItem = SC.View.extend
  contentBinding: 'parentView.parentView.content.stop'
  classNameBindings: ['content.hover']
  classNames: 'stop'
  template: SC.Handlebars.compile """
  <div class="times">
    {{arriveTime}}
    {{#if leaveTime}}
      - {{leaveTime}}
    {{/if}}
  </div>
  {{view Sensor.Views.AddressView contentBinding="content.addressMessage"}}
  """
  mouseEnter: -> @setPath('content.hover',true)
  mouseLeave: -> @setPath('content.hover',false)
  leaveTime: ( ->
    if time = @getPath('content.leaveTime')
      time.toFormattedString('%H:%M')
    else
      'now' if @getPath('content.arriveTime').toFormattedString('%Y-%m-%d') == SC.DateTime.create().toFormattedString('%Y-%m-%d')
  ).property('content.leaveTime')
  arriveTime: ( ->
    if time = @getPath('content.arriveTime')
      time.toFormattedString('%H:%M')
  ).property('content.arriveTime')
