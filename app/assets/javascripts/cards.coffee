$(document).on 'turbolinks:load', ->
  $(".cards-collection li").click ->
    Turbolinks.visit($(this).attr('data-url'))
  $('.cards-collection li .secondary-content').click (event)->
    event.stopPropagation()
