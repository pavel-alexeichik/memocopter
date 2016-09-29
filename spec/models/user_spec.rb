describe User do
  # it "should have valid factory" do
  #   FactoryGirl.build(:user).should be_valid
  # end

  it { should have_many(:cards) }

  it { should validate_presence_of(:email) }
  xit { should validate_uniqueness_of(:email, case_sensitive: false) }
  it { should validate_presence_of(:display_name) }

  it 'should not create admin user by default' do
    user = User.new
    expect(user).not_to be_admin
  end

end
