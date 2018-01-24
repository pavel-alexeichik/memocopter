class SignupForm
  include Capybara::DSL

  def visit_page
    visit '/'
    self
  end

  def fill_in_with(user)
    within 'form#new_user' do
      fill_in 'user_display_name', with: user.display_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password
    end
    self
  end

  def submit
    within 'form#new_user' do
      click_on 'Sign up'
    end
  end
end
