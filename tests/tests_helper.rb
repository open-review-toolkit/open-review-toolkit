require "test/unit"
require "capybara"
require "capybara/dsl"
require "capybara/poltergeist"
require "middleman"
require "bootstrap-sass"

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, debug: false)
end

Capybara.default_driver = :poltergeist

ENV['MM_ROOT'] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'website'))
middleman_app = ::Middleman::Application.new do ||
  config[:watcher_disable] = true
end

Capybara.app = ::Middleman::Rack.new(middleman_app).to_app do
  set :root, ENV['MM_ROOT']
  set :environment, :development
  set :show_exceptions, false
end

class CapybaraTestCase < Test::Unit::TestCase
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
