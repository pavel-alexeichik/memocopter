class Landing
  showError: (message) ->
    $('.error-messages').removeClass('hide').show().html message

  hideErrors: -> $('.error-messages').hide()

  showSignInForm: ->
    $('.signup-form').fadeOut(600)
    @hideErrors()
    @_showForm '.signin-form'
    @_toggleSignInUpLinks()
    @_focus('.signin-form #user_email')

  showSignUpForm: ->
    $('.signin-form').fadeOut(600)
    @hideErrors()
    @_showForm '.signup-form'
    @_toggleSignInUpLinks()
    @_focus('.signup-form #user_display_name')

  _focus: (selector) ->
    setTimeout (-> $(selector).focus()), 650

  _toggleSignInUpLinks: ->
    $('a.sign-in').toggleClass('hide')
    $('a.sign-up').toggleClass('hide')

  _showForm: (selector) ->
    $(selector).removeClass('hide').hide().delay(600).show(0)

@App.onPageLoad 'body.home-controller.landing-action', ->
  App.landing = new Landing()

  $('.signin-form input, .signup-form input').keyup -> App.landing.hideErrors()

  $('a.sign-in').click (e) ->
    e.preventDefault()
    App.landing.showSignInForm()

  $('a.sign-up').click (e) ->
    e.preventDefault()
    App.landing.showSignUpForm()
