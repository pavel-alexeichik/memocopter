require 'spec_helper'

describe User do
  # it "should have valid factory" do
  #   FactoryGirl.build(:user).should be_valid
  # end

  it { should have_many(:cards_sets) }
  it { should have_many(:cards) }

  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_presence_of(:display_name) }

  it 'shold not create admin user by default' do
    user = User.new
    expect(user).not_to be_admin
  end

end
