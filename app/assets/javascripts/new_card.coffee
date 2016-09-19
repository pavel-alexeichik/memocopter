class NewCardViewModel
  cardQuestion: ko.observable("")
  cardAnswer: ko.observable("")
  constructor: ->
    self = this
    self.submitDisabled = ko.computed ->
      return self.cardQuestion() == '' || self.cardAnswer() == ''
    self.submitDisabled.subscribe (newValue) ->
      $('form#new_card input[type="submit"]').parent().toggleClass('disabled', newValue)
    self.submitDisabled.notifySubscribers()

$(document).on 'turbolinks:load', ->
  vm = new NewCardViewModel()
  form = $('form#new_card')
  ko.applyBindings(vm, form.get(0))
  form.on "ajax:success", (e, data, status, xhr) ->
    $(this).trigger 'reset'
    $(this).find('input#card_question').focus()
