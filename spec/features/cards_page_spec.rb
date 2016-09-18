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

  scenario 'create new card' do
    click_on 'New card'
    expect(page).to have_current_path(new_card_path)
  end

  xscenario 'edit card' do
    card = user.cards.first
    find('.card-question', text: card.question).click
    expect(page).to have_current_path(edit_card_path(card))
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
