require 'rails_helper'

feature 'Landing Page' do
  let(:user_email) { 'john@example.com' }
  let(:user_display_name) { 'John Hopkins' }
  let(:user_password) { 'qweasd' }

  scenario 'sign up with valid user data' do
    visit '/'
    fill_in 'Email', with: user_email
    fill_in 'Password', with: user_password
    fill_in 'Password confirmation', with: user_password
    fill_in 'Display name', with: user_display_name
    click_on 'Sign up'
    expect(page).to have_content('Dashboard')
    user = User.last
    expect(user.email).to eq(user_email)
    expect(user.display_name).to eq(user_display_name)
  end

  xscenario 'sign in with valid user data' do
    pending
  end
end
