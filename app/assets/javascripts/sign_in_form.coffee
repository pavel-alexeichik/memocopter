$(document).onPageLoad ->
  $("#login_form").on("ajax:success", (e, data, status, xhr) ->
    if data.logged_in
      window.location.href = '/'
    else
      App.landing.showError 'Incorrect email or password'
  ).on "ajax:error", (e, xhr, status, error) ->
    window.location.href = '/'
