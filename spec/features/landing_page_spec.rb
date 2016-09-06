require 'rails_helper'

feature 'Landing Page' do
  scenario 'sign up with valid user data' do
    visit '/'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'qweasd'
    fill_in 'Password confirmation', with: 'qweasd'
    fill_in 'Display name', with: 'John Hopkins'
    click_on 'Sign up'
    expect(page).to have_content('Dashboard')
  end
end
