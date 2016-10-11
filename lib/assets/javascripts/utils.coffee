String.prototype.capitalize = -> this.charAt(0).toUpperCase() + this.slice(1)

Array.prototype.swap = (x, y) ->
  b = this[x]
  this[x] = this[y]
  this[y] = b
  this

# Returns a random integer between min (inclusive) and max (inclusive)
# Using Math.round() will give you a non-uniform distribution!
Math.getRandomInt = (min, max) -> Math.floor(Math.random() * (max - min + 1)) + min

$.fn.onPageLoad = (fn) ->
  if this.selector
    $(document).on 'turbolinks:load', =>
      $(this.selector, this.context).each fn
  else
    $(document).on 'turbolinks:load', fn
