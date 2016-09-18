class CardsViewModel
  previousRow: null
  onUpdateFields: false
  activeQuestion: ko.observable("")
  activeAnswer: ko.observable("")
  activeCardId: ko.observable("")

  constructor: ->
    self = this
    for field in ['question', 'answer']
      do (field) ->
        self['active' + field.capitalize()].subscribe (newValue)->
          self.sendUpdateRequestIfChanged(field, newValue)

  activeCardDeletePath: ->
    self = this
    ko.computed ->
      Routes.card_path(self.activeCardId())

  activeRow: -> $('.collapsible.cards-collection > .card-row.active')

  activeRowChanged: ->
    return if this.previousRow? && this.previousRow.hasClass('active')
    this.deactivateRows()
    activeRow = this.activeRow()
    if activeRow.length
      this.previousRow = activeRow
      this.updateFields activeRow
      this.renderTemplateInto activeRow
    else
      this.previousRow = null

  updateFields: (activeRow)->
    this.onUpdateFields = true
    this.activeCardId activeRow.find('.card-id').html()
    this.activeQuestion activeRow.find('.card-question').html()
    this.activeAnswer activeRow.find('.card-answer').html()
    this.onUpdateFields = false

  deactivateRows: ->
    return unless this.previousRow?
    this.previousRow.children().appendTo('#active-card-template')
    this.previousRow.html $('#inactive-card-template').html()

  renderTemplateInto: (element) ->
    element.html('')
    $('#active-card-template').children().appendTo(element)

  sendUpdateRequestIfChanged: (field, value)->
    return if this.onUpdateFields
    return if value == ''
    card = {}
    card[field] = value
    cardJson = {card: card}
    url = Routes.card_path this.activeCardId()
    $.ajax
      url: url
      type:'PUT'
      dataType:'json'
      data: cardJson

$(document).on 'turbolinks:load', ->
  $('.modal-trigger').leanModal()
  $('.collapsible.cards-collection').collapsible()
  cardsViewModel = new CardsViewModel()
  ko.applyBindings(cardsViewModel)
  $('.collapsible.cards-collection').click ->
    cardsViewModel.activeRowChanged()
