require 'spec_helper'

describe CardsSet do
  # it "should have valid factory" do
  #   FactoryGirl.build(:user).should be_valid
  # end

  it { should belong_to(:user) }
  it { should have_many(:cards) }

  xit { should validate_presence_of(:user) }
end
