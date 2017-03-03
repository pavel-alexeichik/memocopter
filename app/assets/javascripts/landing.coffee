$('body.home-controller.landing-action').onPageLoad ->
  $('.sign-in').click (e) ->
    e.preventDefault()
    $('.signup-form').fadeOut(600)
    $('.signin-form').removeClass('hide')
