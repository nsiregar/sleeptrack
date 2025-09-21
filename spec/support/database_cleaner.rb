RSpec.configure do |config|
  config.before(:suite) do |example|
    if !example.metadata[:skip_cleaner]
      DatabaseCleaner.clean_with :truncation
    end
  end

  config.before(:each) do |example|
    if !example.metadata[:skip_cleaner]
      DatabaseCleaner.strategy = :deletion

      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
