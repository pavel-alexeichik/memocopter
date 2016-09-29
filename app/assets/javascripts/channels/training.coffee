App.training = App.cable.subscriptions.create "TrainingChannel",
  _cards: []
  _currentCardIndex: 0
  _loadingCards: true # wait for the server to send initial data
  _waitingForCards: []
  connected: ->
    $('body').addClass('cable-connected')
    @perform('preload_cards')

  disconnected: ->

  received: (data) ->
    existingIds = @_cardsIds()
    for newCard in data.cards
      @_cards.push(newCard) unless existingIds[newCard.id]
    @_loadingCards = false
    @nextCard(fn) for fn in @_waitingForCards
    @_waitingForCards = []

  cardsLoading: -> @_loadingCards

  saveTrainingResult: (cardId, trainingResult) ->
    @perform 'save_training_result', card_id: cardId, training_result: trainingResult
    @_tryPreloadCards()

  nextCard: (fn) ->
    if @_currentCardIndex < @_cards.length
      fn @_cards[@_currentCardIndex++]
    else
      if @_noCardsLeft()
        fn null
      else
        @_waitForCardsLoading fn

  _noCardsLeft: -> @_currentCardIndex == @_cards.length and !@_loadingCards

  _cardsIds: ->
    # new Set((@_cards.map (card) -> card.id)
    set = {}
    set[card.id] = true for card in @_cards
    set

  _tryPreloadCards: ->
    return if @_loadingCards
    @perform('preload_cards') if @_cards.length - @_currentCardIndex <  4

  _waitForCardsLoading: (fn) -> @_waitingForCards.push fn
