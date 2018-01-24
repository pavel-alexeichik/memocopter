feature 'Sign Out', js: true do
  let(:user) { FactoryGirl.create(:default_user) }

  scenario 'sign out from the cards page' do
    sign_in(user)
    visit cards_path
    click_on 'Sign out'
    expect(page).to have_selector('body.home-controller.landing-action')
  end
end
