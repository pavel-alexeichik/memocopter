class NewUserForm
  include Capybara::DSL

  def visit_page
    visit '/'
    self
  end

  def fill_in_with(user)
    fill_in 'Display name', with: user.send(:display_name)
    fill_in 'Email', with: user.send(:email)
    fill_in 'Password', with: user.send(:password)
    fill_in 'Password confirmation', with: user.send(:password_confirmation)
    self
  end

  def submit
    click_on 'Sign up'
  end
end
