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
    card = FactoryGirl.build :card
    card.training_interval = 100.days
    card.save!
    expect(card.reload.training_interval).to eq(100.days)
  end

  it 'should properly initialize next_training_time' do
    expect(card.next_training_time).to eq(card.created_at)
    next_training_time = 3.years.from_now
    card = FactoryGirl.build :card, next_training_time: next_training_time
    card.save!
    expect(card.reload.next_training_time).to eq(next_training_time)
  end

  it 'should not allow too small values for the training_interval' do
    card.training_interval = 2.days
    expect(card.training_interval).to eq(2.days)
    card.training_interval = Card::MIN_TRAINING_INTERVAL - 1.second
    expect(card.training_interval).to eq(Card::MIN_TRAINING_INTERVAL)
  end

  describe 'for_training scope' do
    it 'should return cards that have next_training_time slightly greater than now' do
      card.next_training_time = (Card::TRAINING_TIME_OFFSET / 2).seconds.from_now
      card.save!
      expect(Card.for_training.exists?(card.id)).to be_truthy
    end

    it 'should not return cards that not ready for training' do
      card.next_training_time = Card::TRAINING_TIME_OFFSET.seconds.from_now + 1.hour
      card.save!
      expect(Card.for_training.exists?(card.id)).to be_falsy
    end

    it 'should treat new card as ready for training' do
      expect(Card.for_training.exists?(card.id)).to be_truthy
    end

    it 'should order cards by training_interval descending' do
      user.cards.each_with_index do |card, index|
        card.training_interval = (index + 1).days
        card.save!
      end
      cards = user.cards.for_training
      expect(cards.first.training_interval).to eq(cards.count.days)
      expect(cards.last.training_interval).to eq(1.day)
    end
  end

  describe 'ordered_by_created_at scope' do
    it 'should order cards properly' do
      newest_card = FactoryGirl.build(:newest_card)
      oldest_card = FactoryGirl.build(:oldest_card)
      user.cards << newest_card
      user.cards << oldest_card
      creations = user.cards.ordered_by_created_at.map(&:created_at)
      creations.each.with_index do |created_at, index|
        next if index == 0
        expect(created_at).to be <= creations[index-1]
      end
      expect(creations.first).to eq(newest_card.created_at)
      expect(creations.last).to eq(oldest_card.created_at)
    end
  end

  describe 'where_last_was_wrong scope' do
    it 'should filter cards properly' do
      user.cards.update_all(last_was_wrong: false)
      card1 = user.cards.first
      card1.update(last_was_wrong: true)
      card2 = user.cards.last
      card2.update(last_was_wrong: true)
      ids = [card1.id, card2.id]
      expect(user.cards.where_last_was_wrong.reload.count).to eq(2)
      expect(user.cards.where_last_was_wrong.reload.ids).to match_array(ids)
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

    it 'should not update training interval and next_time when now is not the time for the training' do
      next_training_time = Card::TRAINING_TIME_OFFSET.seconds.from_now + 1.hour
      card.update! training_interval: 2.days, next_training_time: next_training_time
      card.save_training_result(false)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
      card.save_training_result(true)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
    end

    it 'should correctly update last_was_wrong flag' do
      [1.year.from_now, 1.year.ago].each do |next_training_time|
        [true, false].each do |training_result|
          card.next_training_time = next_training_time
          card.last_was_wrong = :stub
          card.save_training_result training_result
          expect(card.reload.last_was_wrong).not_to eq(training_result)
        end
      end
    end
  end # describe 'save training result'
end
