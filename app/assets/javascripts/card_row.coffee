class CardRowViewModel
  cardId: ko.observable("")
  cardQuestion: ko.observable("")
  cardAnswer: ko.observable("")
  addCard: (card) ->
    this.cardId(card.id)
    this.cardQuestion(card.question)
    this.cardAnswer(card.answer)
    $('#card-row-template').clone().insertAfter('.cards-collection .new-card-row')
      .removeClass('hide').attr('id', '').hide().show(1000)

$('body.cards-controller').onPageLoad ->
  cardRowViewModel = new CardRowViewModel()
  ko.applyBindings(cardRowViewModel, $('#card-row-template').get(0))
  $("form#new_card").on "ajax:success", (e, data, status, xhr) ->
    cardRowViewModel.addCard(data)
