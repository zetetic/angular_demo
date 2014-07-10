@QuotesCtrl = ['$scope', '$interval', '$timeout', 'Quotes', 'Preferences', ($scope, $interval, $timeout, Quotes, Preferences) ->
  $scope.selectedSymbol = "" # Symbol being added to selection
  $scope.symbols = [ "AAPL", "CSCO", "GOOG", "HPQ", "INTC", "JNPR", "MSFT", "ORCL", "YHOO"] # Sample list of symbols to drive typeahead
  $scope.selectedSymbols = [] # Selected symbols
  $scope.quotes = [] # Stock quotes
  $scope.wait = 10 # Time limit between updates

  # Get the persisted list of selected symbols on startup. Normally this would be connected to a user.
  # We cheat and store them in the first row of the table. Query returns the de-serialized symbol list
  Preferences.query {}, (data) ->
    $scope.selectedSymbols = (data)

  # When user selects a new symbol, add it to the selection
  $scope.$watch 'selectedSymbol', (sym) ->
    if sym? && sym.length
      $scope.selectedSymbols = _.union($scope.selectedSymbols, [sym])
      $scope.selectedSymbol = ""
      $scope.adding = false

  # Watch the selection for changes.
  $scope.$watch 'selectedSymbols.length', (length) ->
    if length?
      # Persist the preferences
      Preferences.save {id: '1', symbols: JSON.stringify($scope.selectedSymbols)}
      if length is 0
        # Selections list is empty, turn off updating.
        $scope.quotes = []
        $scope.stopTimer()
      else
        # Update the quotes
        refresh()

  # Refresh when the timer has run out
  $scope.$watch 'remaining', (nv, ov) ->
    if nv is 0
      refresh()

  # Retreive the list of quotes for the selection.
  refresh = ->
    $scope.querying = true
    Quotes.query {'symbols[]': $scope.selectedSymbols}, (data) ->
      if data.length
        $scope.quotes = data
      $scope.querying = false
      resetTimer()

  # Reset the timer and set the running flag
  resetTimer = ->
    $scope.stopTimer()
    $scope.remaining = $scope.wait
    $scope.running = true
    $scope.timer =
      $interval(->
        $scope.remaining -= 1
      , 1000, $scope.wait)

  # Reset the timer when the 'resume' button is pressed.
  $scope.resumeTimer = ->
    resetTimer()

  # Stop the timer and unset the running flag
  $scope.stopTimer = ->
    $scope.running = false
    if angular.isDefined($scope.timer)
      $interval.cancel($scope.timer)

  # Cancel adding a symbol from the typeahead control
  $scope.cancel = ->
    $scope.adding = false
    $scope.selectedSymbol = ""

  # Remove a symbol from the selection
  $scope.removeSymbol = (symbol) ->
    $scope.selectedSymbols = _.reject $scope.selectedSymbols, (s) -> s is symbol

  # Filter the universe of symbols and omit any already selected
  $scope.notSelected = (symbol) ->
    !_.contains($scope.selectedSymbols, symbol)
]
