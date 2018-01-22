class @TrainingViewModel
  shouldShowAnswer: ko.observable(false)
  trainingSessionFinished: ko.observable(false)
  currentCard: ko.observable({})
  cardsLoaded: ko.observable(false)
  progress: null
  _dataProvider: null

  constructor: ->
    @_dataProvider = ko.observable(App.training)
    @progress = new Progress(@_dataProvider)
    @_showNextCard()
    @currentCard.subscribe @_utterCard.bind(this)
    @_dataProvider().onUpdate => @_dataProvider.valueHasMutated()

  shouldShowLearnWrongCardsButton: -> @wrongCardsCount() > 0 && !@isWrongCardsMode()

  isWrongCardsMode: -> @currentCard().last_was_wrong

  wrongCardsCount: -> @_dataProvider().wrongCardsCount()

  processKeypress: (char) ->
    switch char.toLowerCase()
      when ' ' then @showAnswer()
      when 'r' then @processRightAnswer()
      when 'w' then @processWrongAnswer()

  processRightAnswer: -> @_proceedToNextCard(true)

  processWrongAnswer: -> @_proceedToNextCard(false)

  showAnswer: -> @shouldShowAnswer(true)

  learnWrongCards: ->
    @_dataProvider().learnWrongCards()
    @_showNextCard()

  _utterCard: (card) ->
    return unless SpeechSynthesisUtterance?
    return unless speechSynthesis?
    message = new SpeechSynthesisUtterance(card.question)
    speechSynthesis.speak(message)

  _proceedToNextCard: (currentCardResult) ->
    @_dataProvider().saveTrainingResult(@currentCard(), currentCardResult)
    @_showNextCard()

  _showNextCard: ->
    @_dataProvider().nextCard (card) =>
      @cardsLoaded(true)
      if card?
        @currentCard(card)
        @shouldShowAnswer(false)
      else
        @trainingSessionFinished(true)


class Progress
  constructor: (dataProvider) -> @_dataProvider = dataProvider
  text: -> "Progress: #{@current()} / #{@total()}"
  percent: -> (@current() - 1) * 100 / @total()
  current: -> @_dataProvider().currentCardIndex()
  total: -> @_dataProvider().totalCardsCount()


@App.onPageLoad 'body.training-controller', ->
  window.tvm = new TrainingViewModel()
  ko.applyBindings(tvm, $('#training-view').get(0))
  $(document).bind 'keypress.training', (event) ->
    if $('body.training-controller').length > 0
      char = String.fromCharCode(event.which)
      tvm.processKeypress(char)
    else
      $(document).unbind 'keypress.training'
