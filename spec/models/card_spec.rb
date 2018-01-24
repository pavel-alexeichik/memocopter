describe Card do
  let(:user) { create(:default_user) }
  let(:card) { user.cards.first }

  it 'has valid factory' do
    expect(card).to be_valid
  end

  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_presence_of(:question) }
  it { is_expected.to validate_presence_of(:answer) }

  context 'when card created without setting #training_interval' do
    it 'initializes #training_interval with the predefined value' do
      expect(card.training_interval).to eq(Card::INITIAL_TRAINING_INTERVAL)
    end
  end

  context 'when card created with initialized #training_interval' do
    it 'persists the given value' do
      card = build :card
      card.training_interval = 100.days
      card.save!
      expect(card.reload.training_interval).to eq(100.days)
    end
  end

  context 'when card created without setting #next_training_time' do
    it 'initializes #next_training_time with #created_at value' do
      expect(card.next_training_time).to eq(card.created_at)
    end
  end

  context 'when card created with initialized #next_training_time' do
    it 'persists the given value' do
      next_training_time = 3.years.from_now
      card = build :card, next_training_time: next_training_time
      card.save!
      expect(card.reload.next_training_time).to eq(next_training_time)
    end
  end

  describe '#training_interval=' do
    it 'does not allow too small values' do
      card.training_interval = Card::MIN_TRAINING_INTERVAL - 1.second
      expect(card.training_interval).to eq(Card::MIN_TRAINING_INTERVAL)
    end

    it 'allows values greater or eq to the predefined min interval' do
      card.training_interval = 2.days
      expect(card.training_interval).to eq(2.days)
    end
  end

  describe '.for_training scope' do
    it 'returns cards that have next_training_time slightly greater than now' do
      card.next_training_time = (Card::TRAINING_TIME_OFFSET / 2).seconds.from_now
      card.save!
      expect(described_class.for_training.exists?(card.id)).to be_truthy
    end

    it 'does not return cards that not ready for training' do
      card.next_training_time = Card::TRAINING_TIME_OFFSET.seconds.from_now + 1.hour
      card.save!
      expect(described_class.for_training.exists?(card.id)).to be_falsy
    end

    it 'treats new card as ready for training' do
      expect(described_class.for_training.exists?(card.id)).to be_truthy
    end

    it 'orders cards by training_interval descending' do
      user.cards.each_with_index do |card, index|
        card.training_interval = (index + 1).days
        card.save!
      end
      cards = user.cards.for_training
      expect(cards.first.training_interval).to eq(cards.count.days)
      expect(cards.last.training_interval).to eq(1.day)
    end

    it 'does not include cards that marked as wrong' do
      user.cards.each { |card| card.update(next_training_time: 1.year.from_now) }
      wrong_card = create(:card, :wrong)
      ready_card = create(:card)
      user.cards << wrong_card
      user.cards << ready_card
      expect(user.cards.for_training.ids).to eq([ready_card.id])
    end
  end

  describe 'ordered_by_created_at scope' do
    it 'orders cards properly' do
      newest_card = build(:newest_card)
      oldest_card = build(:oldest_card)
      user.cards << newest_card
      user.cards << oldest_card
      creations = user.cards.ordered_by_created_at.map(&:created_at)
      creations.each.with_index do |created_at, index|
        next if index.zero?
        expect(created_at).to be <= creations[index - 1]
      end
      expect(creations.first).to eq(newest_card.created_at)
      expect(creations.last).to eq(oldest_card.created_at)
    end
  end

  describe 'where_last_was_wrong scope' do
    it 'filters cards properly' do
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

  describe 'where_last_was_right scope' do
    it 'filters cards properly' do
      user.cards.update_all(last_was_wrong: true)
      card1 = user.cards.first
      card1.update(last_was_wrong: false)
      card2 = user.cards.last
      card2.update(last_was_wrong: false)
      ids = [card1.id, card2.id]
      expect(user.cards.where_last_was_right.reload.count).to eq(2)
      expect(user.cards.where_last_was_right.reload.ids).to match_array(ids)
    end
  end

  describe 'save training result' do
    let(:current_time) { Time.zone.now }

    before do
      allow(Time).to receive(:now).and_return(current_time)
    end

    context 'when answer is right' do
      it 'increases training_interval twice' do
        card.training_interval = 2.days
        card.save_training_result(true)
        expect(card.reload.training_interval).to eq(4.days)
      end

      it 'updates next_training_time correctly' do
        card.training_interval = 2.days
        card.save_training_result(true)
        expect(card.reload.next_training_time).to eq(current_time + 4.days)
      end
    end

    context 'when answer is wrong' do
      it 'decreases training_interval properly' do
        card.training_interval = 2.days
        card.save_training_result(false)
        expect(card.reload.training_interval).to eq(1.5.days)
      end

      it 'updates next_training_time correctly' do
        card.training_interval = 2.days
        card.save_training_result(false)
        expect(card.reload.next_training_time).to eq(current_time + 1.5.days)
      end
    end

    it 'does not update training interval and next_time when now is not the time for training' do
      next_training_time = Card::TRAINING_TIME_OFFSET.seconds.from_now + 1.hour
      card.update! training_interval: 2.days, next_training_time: next_training_time
      card.save_training_result(false)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
      card.save_training_result(true)
      expect(card.reload.next_training_time).to eq(next_training_time)
      expect(card.reload.training_interval).to eq(2.days)
    end

    it 'updates last_was_wrong flag correctly' do
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
