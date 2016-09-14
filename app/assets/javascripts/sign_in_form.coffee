$(document).on 'turbolinks:load', ->
  $("#login_form").on("ajax:success", (e, data, status, xhr) ->
    if data.logged_in
      window.location.href = '/'
    else
      $('body').append "<p>Incorrect password or email!</p>"
  ).on "ajax:error", (e, xhr, status, error) ->
    window.location.href = '/'
