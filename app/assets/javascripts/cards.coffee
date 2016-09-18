class CardsViewModel
  previousRow: null
  activeQuestion: ko.observable("")
  activeAnswer: ko.observable("")
  activeRow: -> $('.collapsible.cards-collection > li.active')
  activeRowChanged: ->
    return if this.previousRow? && this.previousRow.hasClass('active')
    this.deactivateRows()
    activeRow = this.activeRow()
    this.previousRow = activeRow
    this.updateFields activeRow
    this.renderTemplateInto activeRow
  updateFields: (activeRow)->
    this.activeQuestion activeRow.find('.card-question').html()
    this.activeAnswer activeRow.find('.card-answer').html()
  deactivateRows: ->
    return unless this.previousRow?
    this.previousRow.children().appendTo('#active-card-template')
    this.previousRow.html $('#inactive-card-template').html()
  renderTemplateInto: (element) ->
    element.html('')
    $('#active-card-template').children().appendTo(element)

$(document).on 'turbolinks:load', ->
  $('.collapsible.cards-collection').collapsible()
  cardsViewModel = new CardsViewModel()
  ko.applyBindings(cardsViewModel)
  $('.collapsible.cards-collection').click ->
    cardsViewModel.activeRowChanged()
