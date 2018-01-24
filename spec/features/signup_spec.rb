require_relative '../support/signup_form.rb'

feature 'Sign Up', js: true do
  let(:user) { build(:user) }

  scenario 'sign up with valid user data' do
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_selector('body.home-controller.dashboard-action')
    created_user = User.last
    expect(created_user.email).to eq(user.email)
    expect(created_user.display_name).to eq(user.display_name)
  end

  scenario 'cannot sign up without email' do
    user.email = ''
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Email can't be blank")
  end

  scenario 'cannot sign up without password' do
    user.password = ''
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Password can't be blank")
  end

  scenario 'cannot sign up without display name' do
    user.display_name = ''
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Display name can't be blank")
  end

  scenario 'cannot sign up with existing email' do
    user = create(:default_user)
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content('Email has already been taken')
  end
end
