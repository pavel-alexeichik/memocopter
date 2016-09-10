feature 'Log Out', js: true do
  let(:user) { FactoryGirl.create(:default_user) }

  scenario 'logout from the dashboard page' do
    sign_in(user)
    visit '/'
    click_on 'Log out'
    expect(page).to have_content('Landing')
  end
end
