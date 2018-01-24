class LoginForm
  include Capybara::DSL

  def visit_page
    visit '/'
    self
  end

  def click_sign_in_link
    find('.nav-links-wrapper .sign-in').click
    self
  end

  def fill_in_with(user)
    click_sign_in_link
    within 'form#login_form' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
    end
    self
  end

  def submit
    click_on 'Log in'
  end
end
