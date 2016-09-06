require 'rails_helper'

feature 'Home Page' do
  scenario 'welcome message' do
    visit '/'
    expect(page).to have_content('Welcome')
  end
end
