describe User do
  # it "should have valid factory" do
  #   FactoryGirl.build(:user).should be_valid
  # end

  it { is_expected.to have_many(:cards) }

  it { is_expected.to validate_presence_of(:email) }
  xit { is_expected.to validate_uniqueness_of(:email, case_sensitive: false) }
  it { is_expected.to validate_presence_of(:display_name) }

  it 'does not create admin user by default' do
    user = described_class.new
    expect(user).not_to be_admin
  end
end
