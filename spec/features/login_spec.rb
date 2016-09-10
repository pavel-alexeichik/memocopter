require 'rails_helper'
require_relative '../support/login_form.rb'

feature 'Log In', js: true do
  let!(:user) { FactoryGirl.create(:default_user) }

  scenario 'login with valid user data' do
    expect(User.last.email).to eq(user.email)
    LoginForm.new.visit_page.fill_in_with(user).submit
    using_wait_time(1) do
      expect(page).to have_content('Dashboard')
    end
  end

  scenario 'cannot login with invalid email' do
    user.email = 'not_working_email@example.com'
    LoginForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Incorrect password or email")
  end
end
