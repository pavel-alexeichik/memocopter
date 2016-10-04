class @TrainingViewModel
  shouldShowAnswer: ko.observable(false)
  trainingSessionFinished: ko.observable(false)
  currentCard: ko.observable({})
  wrongCards: ko.observableArray()
  _dataProvider: ko.observable(null)

  shouldShowLearnWrongCardsButton: -> ko.computed =>
    @wrongCards().length != 0 && !(@_dataProvider() instanceof WrongCardsProvider)

  processRightAnswer: -> @_proceedToNextCard(true)

  processWrongAnswer: ->
    @wrongCards.push @currentCard()
    @_proceedToNextCard(false)

  showAnswer: -> @shouldShowAnswer(true)

  processKeypress: (char) ->
    switch char.toLowerCase()
      when ' ' then @showAnswer()
      when 'r' then @processRightAnswer()
      when 'w' then @processWrongAnswer()

  learnWrongCards: (interrupted = true) ->
    @_interruptedCard = if interrupted then @currentCard() else null
    @_dataProvider(@_getWrongCardsProvider())
    @_showNextCard()

  constructor: ->
    @_dataProvider(App.training)
    @_showNextCard()
    @currentCard.subscribe @_speakCard.bind(this)

  _speakCard: (card) ->
    return unless SpeechSynthesisUtterance?
    return unless speechSynthesis?
    message = new SpeechSynthesisUtterance(card.question)
    speechSynthesis.speak(message)

  _proceedToNextCard: (currentCardResult) ->
    @_dataProvider().saveTrainingResult(@currentCard().id, currentCardResult)
    @_showNextCard()

  _showNextCard: ->
    @_dataProvider().nextCard (card) =>
      if card?
        @currentCard(card)
        @shouldShowAnswer(false)
      else
        @_noCardsLeft()

  _getWrongCardsProvider: ->
    @_wrongCardsProvider ?= new WrongCardsProvider(@wrongCards())

  _learnNewCards: ->
    @_dataProvider(App.training)
    if @_interruptedCard
      @currentCard(@_interruptedCard)
    else
      @trainingSessionFinished(true)

  _noCardsLeft: ->
    if @_dataProvider() instanceof WrongCardsProvider
      @_learnNewCards()
    else if @wrongCards().length
      @learnWrongCards(false)
    else
      @trainingSessionFinished(true)


class WrongCardsProvider
  constructor: (wrongCardsQueue) -> @_cardsQueue = wrongCardsQueue
  nextCard: (fn) -> fn(@_cardsQueue.shift() || null)
  saveTrainingResult: (cardId, trainingResult) ->
  cardsLoading: -> false


$('body.training-controller').onPageLoad ->
  window.tvm = new TrainingViewModel()
  ko.applyBindings(tvm, $('#training-view').get(0))
  $(document).bind 'keypress.training', (event) ->
    if $('body.training-controller').length > 0
      char = String.fromCharCode(event.which)
      tvm.processKeypress(char)
    else
      $(document).unbind 'keypress.training'
