class LoginForm
  include Capybara::DSL

  def visit_page
    visit '/'
    self
  end

  def fill_in_with(user)
    within 'form#login_form' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
    end
    self
  end

  def submit
    click_on 'Log in'
  end
end
