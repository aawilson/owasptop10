task :environment do
  require 'config/environment'
  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end
