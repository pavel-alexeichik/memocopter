feature 'Try as guest', js: true do
  scenario 'click "TRY AS GUEST" link' do
    visit '/'
    users_count = User.count
    find('.try-as-guest').click
    expect(page).to have_content('Welcome to Memocopter!')
    expect(page).to have_content('Currently you are logged in as guest.')
    guest = User.last
    expect(guest).to be_guest
    User.uncached do
      expect(User.count).to eq(users_count + 1)
    end
  end
end
