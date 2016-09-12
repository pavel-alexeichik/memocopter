feature 'Sign Out', js: true do
  let(:user) { FactoryGirl.create(:default_user) }

  scenario 'sign out from the dashboard page' do
    sign_in(user)
    visit dashboard_path
    click_on 'Sign out'
    expect(page).to have_content('Landing')
  end
end
