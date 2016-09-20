class CardsViewModel
  previousRow: null
  onUpdateFields: false

  cardQuestion: ko.observable("")
  cardAnswer: ko.observable("")
  cardId: ko.observable("")

  constructor: ->
    self = this
    for field in ['question', 'answer']
      do (field) ->
        self['card' + field.capitalize()].subscribe (newValue)->
          self.sendUpdateRequestIfChanged(field, newValue)

  activeCardDeletePath: ->
    self = this
    ko.computed ->
      Routes.card_path(self.cardId())

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
    this.cardId activeRow.find('.card-id').html()
    this.cardQuestion activeRow.find('.card-question').html()
    this.cardAnswer activeRow.find('.card-answer').html()
    this.onUpdateFields = false

  deactivateRows: ->
    return unless this.previousRow?
    this.previousRow.children().appendTo('#active-card-template')
    this.previousRow.html $('#inactive-card-template-container li').html()

  renderTemplateInto: (element) ->
    element.html('')
    $('#active-card-template').children().appendTo(element)

  sendUpdateRequestIfChanged: (field, value)->
    return if this.onUpdateFields
    return if value == ''
    card = {}
    card[field] = value
    cardJson = {card: card}
    url = Routes.card_path this.cardId()
    $.ajax
      url: url
      type:'PUT'
      dataType:'json'
      data: cardJson

$('body.cards-controller').onPageLoad ->
  $('.modal-trigger').leanModal()
  $('.collapsible.cards-collection').collapsible()
  cardsViewModel = new CardsViewModel()
  $('.bind-to-cards-view').each -> ko.applyBindings(cardsViewModel, $(this).get(0))
  $('.collapsible.cards-collection').click ->
    cardsViewModel.activeRowChanged()
  $('.cards-collection .collapsible-header').click ->
    focus = -> $('.cards-collection li.active input.grab-focus').focus()
    setTimeout(focus, 200)
