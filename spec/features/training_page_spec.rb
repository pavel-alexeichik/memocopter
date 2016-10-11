feature 'Training page', js: true do
  let(:user) { FactoryGirl.create(:default_user) }
  let(:cards) { user.cards.for_training }
  let(:cards_ar) { cards.to_a.freeze }

  before :each do
    visit_page unless self.class.metadata[:skip_visit_page]
  end

  def visit_page
    sign_in(user)
    visit training_path
    wait_for_cable_connection
    wait_for_js('App.training.cardsLoading() == false')
  end

  def click(action)
    expect(page).to have_css(".#{action}-btn")
    find(".#{action}-btn").trigger 'click'
  end

  def keypress(action)
    key_by_action = { right: :r, wrong: :w, flip: :space }
    fail unless key_by_action[action]
    find('body').send_keys key_by_action[action]
  end

  def perform_action(action, input_type)
    send input_type, action
  end

  def expect_find_question(question)
    expect(page).to have_css('h2.question', text: question)
  end

  def expect_find_highlighted_question(question)
    expect(page).to have_css('h2.question.answer-shown', text: question)
  end

  def expect_find_answer(answer)
    expect(page).to have_css('h2.answer', text: answer)
  end

  def expect_no_answer(answer)
    expect(page).not_to have_content(answer)
    expect(page).not_to have_css('h2.answer')
  end

  def expect_training_session_finished
    expect(page).to have_content('There are no cards to learn at this moment')
    expect(page).not_to have_css('.active-training-session')
  end

  def current_card
    expect(page).to have_css('h2.question')
    question = find('h2.question').text
    cards_ar.find { |card| card.question == question }
  end

  [:click, :keypress].each do |input_type|
    scenario "#{input_type} Flip button" do
      card = current_card
      expect_no_answer card.answer
      perform_action :flip, input_type
      expect_find_highlighted_question card.question
      expect_find_answer card.answer
    end

    [:right, :wrong].each do |action|
      scenario "#{input_type} '#{action}' -> Flip buttons" do
        first_card = current_card
        expect(current_card).to eq(first_card)
        expect_no_answer first_card.answer
        perform_action action, input_type
        second_card = current_card
        expect_find_question second_card.question
        expect(page).not_to have_css('h2.question.answer-shown')
        expect_no_answer second_card.answer
        perform_action :flip, input_type
        expect_find_highlighted_question second_card.question
        expect_find_answer second_card.answer
      end

      scenario "#{input_type} '#{action}' button and check that next_training_time of the card changed" do
        card = current_card
        initial_next_training_time = card.next_training_time
        perform_action action, input_type
        wait_until do
          card.reload.next_training_time != initial_next_training_time
        end
      end

      scenario "#{input_type} '#{action}' button and check that training_interval of the card changed" do
        card = current_card
        initial_interval = Card::MIN_TRAINING_INTERVAL * 2
        card.update! training_interval: initial_interval
        perform_action action, input_type
        wait_until do
          card.reload.training_interval != initial_interval
        end
      end

    end # right / wrong
  end # keypress / click

  scenario "click right button until the end of the session and check that all training cards were displayed" do
    actual_cards = []
    cards_ar.count.times do
      actual_cards << current_card
      click :right
    end
    expect(actual_cards).to match_array(cards_ar)
    expect(actual_cards).not_to eq cards_ar
    actual_cards.each_cons(2) do |c1, c2|
      expect(c1.training_interval).to be <= c2.training_interval
    end
  end

  scenario "create cards with different training intervals and check training order", :skip_visit_page do
    user.cards.destroy_all
    [3, 5, 8].each do |num|
      num.times do
        user.cards << FactoryGirl.build(:card, training_interval: num.days)
      end
    end
    expect(user.cards.reload.count).to eq(3 + 5 + 8)
    visit_page
    [8, 5, 3].each do |num|
      num.times do
        expect(current_card.training_interval).to eq(num.days.to_i)
        click :right
      end
    end
    expect_training_session_finished
  end

  feature "learn wrong cards" do
    let(:button_selector) { 'button.learn-wrong-cards-btn' }
    scenario 'button should be invisible while there are no wrong cards' do
      expect(page).not_to have_css(button_selector)
      (cards_ar.count - 2).times do
        click :right
        expect(page).not_to have_css(button_selector)
      end
      click :wrong
      expect(page).to have_css(button_selector)
      click :right
      expect(page).not_to have_css(button_selector)
    end

    scenario 'mark a card as wrong and learn it in the "learn wrong cards" mode' do
      first_card = current_card
      click :wrong
      second_card = current_card
      click 'learn-wrong-cards'
      expect(current_card).to eq(first_card)
      click :wrong
      expect(current_card).to eq(first_card)
      click :right
      expect(current_card).to eq(second_card)
    end

    scenario 'mark a card as wrong and check that "learn wrong cards" mode started' do
      first_card = current_card
      click :wrong
      (cards_ar.count - 1).times { click :right }
      expect(current_card).to eq(first_card)
      click :wrong
      expect(current_card).to eq(first_card)
      click :right
      expect_training_session_finished
    end

    scenario 'mark few cards as wrong and learn them' do
      # [wwrw]w
      wrong_cards = [current_card]
      click :wrong
      wrong_cards << current_card
      click :wrong
      right_card = current_card
      click :right
      wrong_cards << current_card
      click :wrong
      click 'learn-wrong-cards'
      expect(wrong_cards).to include(current_card)
      click :wrong
      expect(wrong_cards).to include(current_card)
      last_card = current_card
      click :right
      wrong_cards.delete last_card
      expect(wrong_cards).to include(current_card)
      click :wrong
      expect(wrong_cards).to include(current_card)
      last_card = current_card
      click :right
      wrong_cards.delete last_card
      expect(wrong_cards).to include(current_card)
      last_card = current_card
      click :right
      wrong_cards.delete last_card
      expect(wrong_cards).to be_empty
      last_card = cards.reload.order(:updated_at).first
      expect(current_card).to eq(last_card)
      click :wrong
      expect(current_card).to eq(last_card)
      click :wrong
      expect(current_card).to eq(last_card)
      click :right
      expect_training_session_finished
    end

    scenario 'click "learn wrong cards" button and check that it dissapeared' do
      click :wrong
      expect(page).to have_content('Learn 1 wrong cards')
      click 'learn-wrong-cards'
      expect(page).not_to have_content('Learn 1 wrong cards')
      click :right
      expect(page).not_to have_content('Learn 1 wrong cards')
      click :wrong
      expect(page).to have_content('Learn 1 wrong cards')
      4.times { click :right }
      expect_training_session_finished
      expect(page).not_to have_content('Learn wrong cards')
    end

    scenario 'dynamically update "learn wrong cards" text' do
      click :wrong
      expect(page).to have_content('Learn 1 wrong cards')
      click :wrong
      expect(page).to have_content('Learn 2 wrong cards')
      click :right
      expect(page).to have_content('Learn 2 wrong cards')
      click 'learn-wrong-cards'
      expect(page).not_to have_content('Learn 2 wrong cards')
    end
  end # feature "learn wrong cards"

  feature 'current progress' do
    def expect_progress(current:, total: cards_ar.count)
      expect(page).to have_css('.progress-text', text: "Progress: #{current} / #{total}")
      expected_percent = (current - 1) * 100 / total
      expected_style = "width: #{expected_percent}%;"
      expect(page.find('.progress .determinate')['style']).to eq(expected_style)
    end

    scenario 'click right/wrong/learn-wrong and check the progress updates' do
      expect_progress current: 1
      click :right
      expect_progress current: 2
      click :wrong
      expect_progress current: 3
      click :wrong
      expect_progress current: 4
      click 'learn-wrong-cards'
      expect_progress current: 1, total: 2
      click :wrong
      expect_progress current: 1, total: 2
      click :right
      expect_progress current: 2, total: 2
      click :right
      expect_progress current: 4
      click :right
      expect_progress current: 5
      click :wrong
      expect_progress current: 1, total: 1
      click :right
      expect_training_session_finished
    end

    scenario 'learn all cards and check the progress dissapeared' do
      expect(page).to have_css('.progress-text')
      expect(page).to have_css('.progress')
      cards_ar.count.times { click :right }
      expect_training_session_finished
      expect(page).not_to have_css('.progress-text')
      expect(page).not_to have_css('.progress')
    end
  end # fearure 'current progress'

end # feature Training session
