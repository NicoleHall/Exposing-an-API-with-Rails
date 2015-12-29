require 'factory_girl_rails'
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  #FactoryGirl Settings

  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
  begin
    DatabaseCleaner.start
    FactoryGirl.lint
  ensure
    DatabaseCleaner.clean
  end
end
  config.before(:each, type: :controller) do
  FactoryGirl.create(:present)
end

end
