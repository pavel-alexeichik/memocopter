module Utils
  def blur
    find(:css, 'body').click
  end
end

RSpec.configure do |config|
  config.include Utils, type: :feature
end

module WaitHelpers
  def wait_until
    Timeout.timeout(Capybara.default_max_wait_time) do
      while true
        break if yield
        sleep 0.1
      end
    end
  end

  def wait_for_ajax
    wait_for_js('jQuery.active == 0')
  end

  def wait_for_cable_connection
    wait_until do
      page.has_css?('body.cable-connected')
    end
  end

  def wait_for_js(script)
    wait_until do
      page.evaluate_script(script)
    end
  end
end

RSpec.configure do |config|
  config.include WaitHelpers, type: :feature
end
