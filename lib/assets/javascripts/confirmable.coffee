$(document).on 'turbolinks:load', ->
  $(".confirmable").click (event)->
    event.preventDefault()
    url = $(this).attr('href');
    modalId = $(this).attr('data-modal-id')
    $(modalId).find('.confirm-success').attr('href', url)
    $(modalId).openModal()
