$('body.home-controller.landing-action').onPageLoad ->
  $('a.sign-in').click (e) ->
    e.preventDefault()
    $('.signup-form').fadeOut(600)
    $('.signin-form').removeClass('hide').hide().delay(600).show(0)
    $('a.sign-up').removeClass('hide').show()
    $('a.sign-in').hide()
    setTimeout (-> $('.signin-form #user_email').focus()), 650

  $('a.sign-up').click (e) ->
    e.preventDefault()
    $('.signin-form').fadeOut(600)
    $('.signup-form').removeClass('hide').hide().delay(600).show(0)
    $('a.sign-in').removeClass('hide').show()
    $('a.sign-up').hide()
    $('.signup-form #user_display_name').focus().select()
    setTimeout (-> $('.signup-form #user_display_name').focus()), 650
