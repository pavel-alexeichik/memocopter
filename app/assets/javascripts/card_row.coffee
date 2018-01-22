class CardRowViewModel
  cardId: ko.observable("")
  cardQuestion: ko.observable("")
  cardAnswer: ko.observable("")
  addCard: (card) ->
    this.cardId(card.id)
    this.cardQuestion(card.question)
    this.cardAnswer(card.answer)
    $('#card-row-template-container li').clone()
      .insertAfter('.cards-collection .new-card-row').hide().show(1000)

@App.onPageLoad 'body.cards-controller', ->
  cardRowViewModel = new CardRowViewModel()
  ko.applyBindings(cardRowViewModel, $('#card-row-template-container').get(0))
  $("form#new_card").on "ajax:success", (e, data, status, xhr) ->
    cardRowViewModel.addCard(data)
