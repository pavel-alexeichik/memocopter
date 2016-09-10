require_relative '../support/signup_form.rb'

feature 'Sign Up' do
  let(:user) { FactoryGirl.build(:user) }

  scenario 'sign up with valid user data' do
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content('Dashboard')
    created_user = User.last
    expect(created_user.email).to eq(user.email)
    expect(created_user.display_name).to eq(user.display_name)
  end

  scenario 'cannot sign up without email' do
    user.email = ''
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Email can't be blank")
  end

  scenario 'cannot sign up with existing email' do
    user = FactoryGirl.create(:default_user)
    SignupForm.new.visit_page.fill_in_with(user).submit
    expect(page).to have_content("Email has already been taken")
  end
end
