class @CardsQueue
  _initialized: false
  _resetOnFinish: false
  _groupByTrainingInterval: true

  constructor: (wrongCardsQueue) ->
    @_resetOnFinish ||= wrongCardsQueue
    @_groupByTrainingInterval = !wrongCardsQueue
    @_reset()

  isInitialized: -> @_initialized

  add: (cards) ->
    cards = [cards] unless cards instanceof Array
    @_cards.push(card) for card in cards
    @_initialized = true

  next: ->
    if @isInitialized() && @_nextIndex < @count()
      @_reorder()
      return @_cards[@_nextIndex++]
    else
      @_reset() if @_resetOnFinish
      return null

  currentIndex: -> @_nextIndex

  isExhausted: -> @isInitialized() && @_nextIndex == @count()

  isAboutToBeExhausted: -> @count() - @_nextIndex < 4

  _reset: ->
    @_nextIndex = 0
    @_cards = []

  pushBackCurrent: ->
    @_nextIndex--
    @_cards.swap(@_nextIndex, @count() - 1)

  rewind: -> @_nextIndex--

  existingIds: ->
    set = {}
    set[card.id] = true for card in @_cards
    set

  count: -> @_cards.length

  _nextCard: -> @_cards[@_nextIndex]

  _reorder: ->
    indexToSwap = Math.getRandomInt(@_nextIndex, @count() - 1)
    if @_groupByTrainingInterval
      sameIntervalLastIndex = @_nextIndex
      currentTrainingInterval = @_nextCard().training_interval
      while sameIntervalLastIndex < @count()
        if @_cards[sameIntervalLastIndex].training_interval == currentTrainingInterval
          sameIntervalLastIndex++
        else
          break
      indexToSwap = Math.getRandomInt(@_nextIndex, sameIntervalLastIndex - 1)
    @_cards.swap(@_nextIndex, indexToSwap)
