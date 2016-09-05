require 'spec_helper'

describe Card do
  # it "should have valid factory" do
  #   FactoryGirl.build(:user).should be_valid
  # end

  it { should belong_to(:cards_set) }

  it { should validate_presence_of(:question) }
  it { should validate_presence_of(:answer) }
  xit { should validate_presence_of(:cards_set) }

  xit 'should not be public by default'
  xit 'should have position set to 0 by default'
end
