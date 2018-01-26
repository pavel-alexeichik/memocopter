describe User do
  # it "should have valid factory" do
  #   build(:user).should be_valid
  # end

  it { is_expected.to have_many(:cards) }

  it { is_expected.to validate_presence_of(:email) }
  xit { is_expected.to validate_uniqueness_of(:email, case_sensitive: false) }
  it { is_expected.to validate_presence_of(:display_name) }

  it 'does not create admin user by default' do
    user = described_class.new
    expect(user).not_to be_admin
  end

  it 'does not create guest user by default' do
    user = described_class.new
    expect(user).not_to be_guest
  end

  describe '.create_guest' do
    let(:guest) { User.create_guest }

    it 'creates and returns a new user' do
      expect(guest).to be_instance_of(User)
      expect(guest).to be_persisted
    end

    it 'it marks the new user as guest' do
      expect(guest).to be_guest
    end

    it 'creates a new user with cards' do
      expect(guest.cards.count).to eq(20)
    end
  end
end
