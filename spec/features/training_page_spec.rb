feature 'Training page', js: true do
  let(:user) { FactoryGirl.create(:default_user) }
  let!(:training_cards) { user.cards.for_training.to_a }
  let!(:training_card) { training_cards.first }
  let!(:first_training_card) { training_card }
  let!(:second_training_card) { training_cards.second }
  let!(:third_training_card) { training_cards.third }
  let!(:fourth_training_card) { training_cards.fourth }
  let!(:fifth_training_card) { training_cards.fifth }

  before :each do
    sign_in(user)
    visit training_path
    wait_for_cable_connection
    wait_for_js('App.training.cardsLoading() == false')
  end

  def click(action)
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

  def expect_current_card_to_be(card)
    card = (send "#{card}_training_card") if card.is_a?(Symbol)
    expect_find_question card.question
    expect_no_answer card.answer
  end

  [:click, :keypress].each do |input_type|
    scenario "#{input_type} Flip button" do
      expect_current_card_to_be :first
      perform_action :flip, input_type
      expect_find_highlighted_question training_card.question
      expect_find_answer training_card.answer
    end

    [:right, :wrong].each do |action|
      scenario "#{input_type} '#{action}' -> Flip buttons" do
        expect_current_card_to_be :first
        perform_action action, input_type
        expect_find_question second_training_card.question
        expect(page).not_to have_css('h2.question.answer-shown')
        expect_no_answer second_training_card.answer
        perform_action :flip, input_type
        expect_find_highlighted_question second_training_card.question
        expect_find_answer second_training_card.answer
      end

      scenario "#{input_type} '#{action}' button and check that next_training_time of the card changed" do
        initial_next_training_time = training_card.next_training_time
        perform_action action, input_type
        wait_until do
          training_card.reload.next_training_time != initial_next_training_time
        end
      end

      scenario "#{input_type} '#{action}' button and check that training_interval of the card changed" do
        initial_interval = Card::MIN_TRAINING_INTERVAL * 2
        training_card.update! training_interval: initial_interval
        initial_interval = training_card.training_interval
        perform_action action, input_type
        wait_until do
          training_card.reload.training_interval != initial_interval
        end
      end

    end # right / wrong
  end # keypress / click

  scenario "click right button until the end of the session and check that all training cards where displayed" do
    training_cards.each do |card|
      expect_current_card_to_be card
      click :right
    end
    expect_training_session_finished
  end

  feature "learn wrong cards" do
    let(:button_selector) { 'button.learn-wrong-cards-btn' }
    scenario 'button should be invisible while there are no wrong cards' do
      expect(page).not_to have_css(button_selector)
      right_cards_count = training_cards.count - 2
      training_cards.first(right_cards_count).each do |card|
        click :right
        expect(page).not_to have_css(button_selector)
      end
      click :wrong
      expect(page).to have_css(button_selector)
      click :right
      expect(page).not_to have_css(button_selector)
    end

    scenario 'mark a card as wrong and learn it in the "learn wrong cards" mode' do
      click :wrong
      expect_current_card_to_be :second
      click 'learn-wrong-cards'
      expect_current_card_to_be :first
      click :wrong
      expect_current_card_to_be :first
      click :right
      expect_current_card_to_be :second
    end

    scenario 'mark a card as wrong and check that "learn wrong cards" mode started' do
      click :wrong
      (training_cards.count - 1).times { click :right }
      expect_current_card_to_be :first
      click :wrong
      expect_current_card_to_be :first
      click :right
      expect_training_session_finished
    end

    scenario 'mark few cards as wrong and learn them' do
      click :wrong
      click :wrong
      click :right
      click :wrong
      click 'learn-wrong-cards'
      expect_current_card_to_be :first
      click :wrong
      expect_current_card_to_be :second
      click :right
      expect_current_card_to_be :fourth
      click :wrong
      expect_current_card_to_be :first
      click :right
      expect_current_card_to_be :fourth
      click :right
      expect_current_card_to_be :fifth
      click :wrong
      expect_current_card_to_be :fifth
      click :wrong
      expect_current_card_to_be :fifth
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
    def expect_progress(current:, total: training_cards.count)
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
      training_cards.count.times { click :right }
      expect_training_session_finished
      expect(page).not_to have_css('.progress-text')
      expect(page).not_to have_css('.progress')
    end
  end # fearure 'current progress'

end # feature Training session
