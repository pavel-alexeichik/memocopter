require 'test_helper'

class CardsSetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cards_set = cards_sets(:one)
  end

  test "should get index" do
    get cards_sets_url
    assert_response :success
  end

  test "should get new" do
    get new_cards_set_url
    assert_response :success
  end

  test "should create cards_set" do
    assert_difference('CardsSet.count') do
      post cards_sets_url, params: { cards_set: { name: @cards_set.name, user_id: @cards_set.user_id } }
    end

    assert_redirected_to cards_set_url(CardsSet.last)
  end

  test "should show cards_set" do
    get cards_set_url(@cards_set)
    assert_response :success
  end

  test "should get edit" do
    get edit_cards_set_url(@cards_set)
    assert_response :success
  end

  test "should update cards_set" do
    patch cards_set_url(@cards_set), params: { cards_set: { name: @cards_set.name, user_id: @cards_set.user_id } }
    assert_redirected_to cards_set_url(@cards_set)
  end

  test "should destroy cards_set" do
    assert_difference('CardsSet.count', -1) do
      delete cards_set_url(@cards_set)
    end

    assert_redirected_to cards_sets_url
  end
end
