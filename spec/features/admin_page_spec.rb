require_relative '../support/login_form.rb'

feature 'Admin page', js: true do
  let!(:admin_route) { '/admin' }
  let!(:regular_user) { create(:default_user) }
  let!(:admin_user) { create(:admin_user) }

  scenario 'visit admin page by admin user' do
    sign_in(admin_user)
    visit admin_route
    expect(current_path).to eq(admin_route)
  end

  scenario 'visit admin page by regular user' do
    sign_in(regular_user)
    visit admin_route
    expect(current_path).to eq('/')
  end
end

