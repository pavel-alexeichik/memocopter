feature 'Cards page', js: true do
  let(:user) { FactoryGirl.create(:default_user) }
  before :each do
    sign_in(user)
    visit cards_path
  end

  scenario 'display cards list of the user' do
    cards_count = user.cards.count
    expect(cards_count).to be > 1
    expect(find('.cards-collection').all('.card-question').count).to eq(cards_count)
  end

  feature 'create card' do
    let(:new_card) { FactoryGirl.build(:card) }
    before :each do
      find('.new-card-row').click
    end

    scenario 'with valid data' do
      within '.new-card-row' do
        fill_in :card_question, with: new_card.question
        fill_in :card_answer, with: new_card.answer
        click_on 'Create'
      end
      sleep 1 # wait for the new row to appear
      expect(user.cards.reload.map(&:question)).to include(new_card.question)
    end
  end

  feature 'edit card' do
    let(:card) { user.cards.first }
    before :each do
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
    before :each do
      expect(user.cards.reload.ids).to include(card.id)
      card_row = find('.cards-collection .card-row', text: card.question)
      card_row.click
      expect(card_row.find('a.delete-link')).to be_visible
      card_row.find('a.delete-link').click
      expect(page).to have_content('Are you sure?')
    end

    scenario 'confirmed' do
      within '#confirm-dialog' do
        click_on 'Delete'
      end
      expect(user.cards.reload.ids).not_to include(card.id)
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
