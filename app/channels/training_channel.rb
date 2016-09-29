# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class TrainingChannel < ApplicationCable::Channel
  def subscribed
    stream_from current_stream
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def save_training_result(data)
    card_id = data['card_id']
    training_result = data['training_result']
    card = current_user.cards.find_by_id(card_id)
    card.save_training_result(training_result) unless card.blank?
  end

  def preload_cards
    cards = current_user.cards.for_training
    ActionCable.server.broadcast current_stream, cards: cards
  end

  private
  def current_stream
    "training_channel_#{current_user.id}"
  end
end
