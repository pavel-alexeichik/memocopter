require 'rails_helper'
require_relative '../support/new_user_form.rb'

feature 'Sign Up' do
  let(:user) { FactoryGirl.build(:user) }

  scenario 'sign up with valid user data' do
    NewUserForm.new.visit_page.fill_in_with(user).submit

    expect(page).to have_content('Dashboard')
    created_user = User.last
    expect(created_user.email).to eq(user.email)
    expect(created_user.display_name).to eq(user.display_name)
  end

  xscenario 'cannot sign up without email' do
  end
end
