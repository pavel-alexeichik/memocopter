require 'rails_helper'

feature 'Sign Up' do
  let(:user) { FactoryGirl.build(:user) }

  scenario 'sign up with valid user data' do
    visit '/'
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    fill_in 'Display name', with: user.display_name
    click_on 'Sign up'
    expect(page).to have_content('Dashboard')
    created_user = User.last
    expect(created_user.email).to eq(user.email)
    expect(created_user.display_name).to eq(user.display_name)
  end

  xscenario 'cannot sign up without email' do
  end
end
