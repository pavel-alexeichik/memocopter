feature 'Cards page', js: true do
  let(:user) { create(:default_user) }
  before do
    unless self.class.metadata[:skip_before]
      sign_in(user)
      visit cards_path
    end
  end

  scenario 'dispay correct number of cards' do
    cards_count = user.cards.count
    expect(find('.cards-collection').all('.card-question').count).to eq(cards_count)
  end

  scenario 'display cards list of the user' do
    user.cards.each do |card|
      expect(page).to have_css('.cards-collection .card-row', text: card.question)
    end
  end

  scenario 'display cards in the correct order' do
    expect_row_to_have_question = lambda do |row_index, question|
      expect(find('.cards-collection').all('.card-question')[row_index].text).to eq(question)
    end
    user.cards.ordered_by_created_at.each.with_index do |card, index|
      expect_row_to_have_question.call(index, card.question)
    end
  end

  scenario 'do not display cards of the other users', skip_before: true do
    user2 = create(:second_user)
    expect(user2.reload.cards.count).to be_positive
    sign_in(user)
    visit cards_path
    expect(find('.cards-collection').all('.card-question').count).to eq(user.cards.count)
    user.cards.each do |card|
      expect(page).to have_css('.cards-collection .card-row', text: card.question)
    end
    user2.cards.each do |card|
      expect(page).not_to have_css('.cards-collection .card-row', text: card.question)
    end
  end

  feature 'create card' do
    before do
      find('.new-card-row').click
    end

    scenario 'without required fields' do
      within '.new-card-row' do
        expect(find('input[type="submit"]')).to be_disabled
      end
    end

    scenario 'with valid data multiple times' do
      2.times do
        new_card = build(:card)
        expect(user.cards.reload.map(&:question)).not_to include(new_card.question)
        within '.new-card-row' do
          fill_in :card_question, with: new_card.question
          fill_in :card_answer, with: new_card.answer
          click_on 'Create'
        end
        expect(page).to have_css('.card-row', text: new_card.question)
        expect(user.cards.reload.map(&:question)).to include(new_card.question)
      end
    end
  end

  feature 'edit card' do
    let(:card) { user.cards.first }
    before do
      find('.card-question', text: card.question).click
    end

    [:question, :answer].each do |field|
      scenario "change #{field}" do
        input = find("input.card-#{field}")
        expect(input.value).to eq(card.send(field))
        new_value = "new-value-#{field}"
        input.set new_value
        blur
        expect(card.reload.send(field)).to eq(new_value)
      end

      scenario "fill #{field} with empty value" do
        input = find("input.card-#{field}")
        original_value = card.send(field)
        expect(input.value).to eq(original_value)
        input.set ''
        blur
        expect(card.reload.send(field)).to eq(original_value)
      end
    end
  end

  feature 'delete card' do
    let(:card) { user.cards.first }
    before do
      expect(user.cards.reload.ids).to include(card.id)
      card_row = find('.cards-collection .card-row', text: card.question)
      card_row.click
      expect(card_row.find('a.delete-link')).to be_visible
      card_row.find('a.delete-link').click
      expect(page).to have_content('Are you sure?')
    end

    scenario 'confirmed' do
      find('#confirm-dialog .confirmed-delete-btn').trigger 'click'
      wait_until { user.cards.reload.ids.include?(card.id) == false }
      expect(page).to have_current_path(cards_path)
      expect(page).not_to have_content(card.question)
    end

    scenario 'not confirmed' do
      within '#confirm-dialog' do
        click_on 'Close'
      end
      expect(user.cards.reload.ids).to include(card.id)
      expect(page).to have_current_path(cards_path)
    end
  end
end
