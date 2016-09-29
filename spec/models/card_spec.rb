describe Card do
  let(:user) { FactoryGirl.create(:default_user) }
  let(:card) { user.cards.first }

  it "should have valid factory" do
    expect(card).to be_valid
  end

  it { should belong_to(:user) }

  it { should validate_presence_of(:question) }
  it { should validate_presence_of(:answer) }

  it 'should properly initialize training_interval' do
    expect(card.training_interval).to eq(Card::INITIAL_TRAINING_INTERVAL)
  end

  it 'should properly initialize next_training_time' do
    expect(card.next_training_time).to eq(card.created_at)
  end

  it 'should not allow too small values for the training_interval' do
    card.training_interval = 2.days
    expect(card.training_interval).to eq(2.days)
    card.training_interval = Card::MIN_TRAINING_INTERVAL - 1.second
    expect(card.training_interval).to eq(Card::MIN_TRAINING_INTERVAL)
  end

  describe 'for_training scope' do
    it 'should return cards that have next_training_time slightly greater than now' do
      card.next_training_time = Time.now + Card::TRAINING_TIME_OFFSET / 2
      card.save!
      expect(Card.for_training.exists?(card.id)).to be_truthy
    end

    it 'should not return cards that not ready for training' do
      card.next_training_time = Time.now + 1.hour + Card::TRAINING_TIME_OFFSET
      card.save!
      expect(Card.for_training.exists?(card.id)).to be_falsy
    end

    it 'should treat new card as ready for training' do
      expect(Card.for_training.exists?(card.id)).to be_truthy
    end
  end

  describe 'save training result' do
    let(:current_time) { Time.now }
    before(:each) do
      allow(Time).to receive(:now).and_return(current_time)
    end
    describe 'when answer is right' do
      it 'should increase training_interval twice' do
        card.training_interval = 2.days
        card.save_training_result(true)
        expect(card.reload.training_interval).to eq(4.days)
      end

      it 'should correctly update next_training_time' do
        card.training_interval = 2.days
        card.save_training_result(true)
        expect(card.reload.next_training_time).to eq(current_time + 4.days)
      end
    end
    describe 'when answer is wrong' do
      it 'should properly decrease training_interval' do
        card.training_interval = 2.days
        card.save_training_result(false)
        expect(card.reload.training_interval).to eq(1.5.days)
      end

      it 'should correctly update next_training_time' do
        card.training_interval = 2.days
        card.save_training_result(false)
        expect(card.reload.next_training_time).to eq(current_time + 1.5.days)
      end
    end

    it 'should not update training data when now is not the time for the training' do
      next_training_time = Time.now + Card::TRAINING_TIME_OFFSET + 1.hour
      card.update! training_interval: 2.days, next_training_time: next_training_time
      card.save_training_result(false)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
      card.save_training_result(true)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
    end
  end # describe 'save training result'

  xit 'should not be public by default'
  xit 'should have position set to 0 by default'
end
