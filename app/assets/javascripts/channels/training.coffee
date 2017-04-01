class TrainingDataProvider
  _loadingCards: true # wait for the server to send initial data
  _waitingForCards: []

  constructor: ->
    @_trainingCards = new CardsQueue()
    @_wrongCards = new CardsQueue(true)
    @_currentQueue = @_trainingCards

  connected: ->
    $('body').addClass('cable-connected')
    @perform('preload_training_cards')
    @perform('preload_wrong_cards')

  disconnected: ->

  received: (data) ->
    if data.cards_type == 'training_cards'
      @_trainingCardsReceived(data.cards)
    else if data.cards_type == 'wrong_cards'
      @_wrongCardsReceived(data.cards)
    else
      new Exception('Unknown type of cards received')
    if @_wrongCards.isInitialized() && @_trainingCards.isInitialized()
      @_allInitialDataReceived()

  _updateListeners: []
  onUpdate: (fn) -> @_updateListeners.push fn
  _notifyUpdate: -> listener() for listener in @_updateListeners

  learnWrongCards: ->
    unless @isWrongCardsMode()
      @_trainingCards.rewind()
      @_switchQueue()

  _allInitialDataReceived: ->
    @_loadingCards = false
    @nextCard(fn) for fn in @_waitingForCards
    @_waitingForCards = []
    @_notifyUpdate()

  _trainingCardsReceived: (cards) -> @_trainingCards.add(@_filterReceivedCards(cards))

  _wrongCardsReceived: (cards) -> @_wrongCards.add(@_filterReceivedCards(cards))

  _filterReceivedCards: (cards) ->
    existingIds = @_allCardsIds()
    filteredCards = []
    for newCard in cards
      filteredCards.push(newCard) unless existingIds[newCard.id]
    filteredCards

  saveTrainingResult: (card, trainingResult) ->
    unless trainingResult
      card.last_was_wrong = true
      if @isWrongCardsMode()
        @_wrongCards.pushBackCurrent()
      else
        @_wrongCards.add(card)
      @_notifyUpdate()
    @perform 'save_training_result', card_id: card.id, training_result: trainingResult
    @_tryPreloadCards()

  nextCard: (fn) ->
    if card = @_fetchNext()
      fn card
    else
      if @_noCardsLeft()
        fn null
      else
        @_waitForCardsLoading fn

  isWrongCardsMode: -> @_currentQueue == @_wrongCards

  currentCardIndex: -> @_currentQueue.currentIndex()
  totalCardsCount: -> @_currentQueue.count()
  wrongCardsCount: -> @_wrongCards.count()

  _switchQueue: ->
    @_currentQueue = if @isWrongCardsMode() then @_trainingCards else @_wrongCards
    @_notifyUpdate()

  _fetchNext: ->
    return null unless @_wrongCards.isInitialized() && @_trainingCards.isInitialized()
    card = @_currentQueue.next()
    unless card
      @_switchQueue()
      card = @_currentQueue.next()
    @_notifyUpdate()
    card

  _noCardsLeft: -> @_currentQueue.isExhausted() and !@_loadingCards

  _allCardsIds: ->
    $.extend(@_trainingCards.existingIds(), @_wrongCards.existingIds())

  _tryPreloadCards: ->
    return if @_loadingCards || @isWrongCardsMode()
    @perform('preload_training_cards') if @_trainingCards.isAboutToBeExhausted()

  _waitForCardsLoading: (fn) -> @_waitingForCards.push fn


$('body.training-controller').onPageLoad ->
  App.training = App.cable.subscriptions.create "TrainingChannel", new TrainingDataProvider()
