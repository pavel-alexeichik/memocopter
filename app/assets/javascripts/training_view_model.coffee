class @TrainingViewModel
  shouldShowAnswer: ko.observable(false)
  trainingSessionFinished: ko.observable(false)
  currentCard: ko.observable({})
  wrongCards: ko.observableArray()
  _dataProvider: ko.observable(null)

  shouldShowLearnWrongCardsButton: -> ko.computed =>
    @wrongCards().length != 0 && !@isWrongCardsMode()()

  isWrongCardsMode: -> ko.computed => @_dataProvider() instanceof WrongCardsProvider

  currentCardIndex: ->
    @currentCard() # current card depends on index
    @_dataProvider().getCurrentCardIndex()

  totalCardsCount: -> @_dataProvider().getTotalCardsCount()

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
    @_dataProvider(new WrongCardsProvider(@wrongCards))
    @_showNextCard()

  constructor: ->
    @_dataProvider(App.training)
    @progress = new Progress(this)
    @_showNextCard()
    @currentCard.subscribe @_speakCard.bind(this)
    @_dataProvider().onDataLoaded => @_dataProvider.valueHasMutated()

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


class Progress
  constructor: (trainingViewModel) -> @_viewModel = trainingViewModel
  text: -> "Progress: #{@current()} / #{@total()}"
  percent: -> (@current() - 1) * 100 / @total()
  current: -> @_viewModel.currentCardIndex()
  total: -> @_viewModel.totalCardsCount()


class WrongCardsProvider
  constructor: (wrongCardsQueue) ->
    @_cardsQueue = wrongCardsQueue
    @_totalCardsCount = wrongCardsQueue().length
    @_currentCardIndex = 1
  nextCard: (fn) -> fn(@_cardsQueue.shift() || null)
  saveTrainingResult: (cardId, trainingResult) -> @_currentCardIndex++ if trainingResult
  cardsLoading: -> false
  getTotalCardsCount: -> @_totalCardsCount
  getCurrentCardIndex: -> @_currentCardIndex


$('body.training-controller').onPageLoad ->
  window.tvm = new TrainingViewModel()
  ko.applyBindings(tvm, $('#training-view').get(0))
  $(document).bind 'keypress.training', (event) ->
    if $('body.training-controller').length > 0
      char = String.fromCharCode(event.which)
      tvm.processKeypress(char)
    else
      $(document).unbind 'keypress.training'
