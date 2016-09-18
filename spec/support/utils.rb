module Utils
  def blur
    find(:css, 'body').click
  end
end

RSpec.configure do |config|
  config.include Utils, type: :feature
end
