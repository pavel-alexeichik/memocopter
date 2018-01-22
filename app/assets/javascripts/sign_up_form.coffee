@App.onPageLoad document, ->
  $("#new_user").on("ajax:success", (e, data, status, xhr) ->
    if data.success
      window.location.href = data.location
    else
      App.landing.showError JSON.parse(data.error_messages).join('</br>')
  ).on "ajax:error", (e, xhr, status, error) ->
    window.location.href = '/'
