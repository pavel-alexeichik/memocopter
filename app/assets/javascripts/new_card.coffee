class NewCardViewModel
  newCardId: ko.observable("")
  newCardQuestion: ko.observable("")
  newCardAnswer: ko.observable("")
  addCard: (card) ->
    this.newCardId(card.id)
    this.newCardQuestion(card.question)
    this.newCardAnswer(card.answer)
    $('#new-card-template').clone().insertAfter('.cards-collection .new-card-row')
      .removeClass('hide').attr('id', '').hide().show()#show(1000)

$(document).on 'turbolinks:load', ->
  newCardViewModel = new NewCardViewModel()
  ko.applyBindings(newCardViewModel, $('#new-card-template').get(0))
  $("form#new_card").on "ajax:success", (e, data, status, xhr) ->
    newCardViewModel.addCard(data)
    $(this).trigger 'reset'
    $(this).find('input#card_question').focus()
