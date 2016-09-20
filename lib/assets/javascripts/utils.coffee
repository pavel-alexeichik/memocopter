String.prototype.capitalize = ->
  this.charAt(0).toUpperCase() + this.slice(1)

$.fn.onPageLoad = (fn) ->
  # console.log this.selector
  if this.selector
    $(document).on 'turbolinks:load', =>
      $(this.selector, this.context).each fn
  else
    $(document).on 'turbolinks:load', fn
