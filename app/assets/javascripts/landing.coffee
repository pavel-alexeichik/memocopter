$('body.home-controller.landing-action').onPageLoad ->
  $('a.sign-in').click (e) ->
    e.preventDefault()
    $('.signup-form').fadeOut(600)
    $('.signin-form').removeClass('hide').show()
    $('a.sign-up').removeClass('hide').show()
    $('a.sign-in').hide()

  $('a.sign-up').click (e) ->
    e.preventDefault()
    $('.signin-form').fadeOut(600)
    $('.signup-form').removeClass('hide').show()
    $('a.sign-in').removeClass('hide').show()
    $('a.sign-up').hide()
