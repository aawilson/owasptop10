require 'active_record/fixtures'
# Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each {|file| require file }

class InitDb < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :birthdate
      t.string :ssn
    end

    create_table :catchphrases do |t|
      t.integer :user_id
      t.string :catchphrase
    end

    add_index(:users, :username)

    Dir[File.join(File.dirname(__FILE__), 'fixtures', '*.yml')].each do |file|
      ActiveRecord::Fixtures.create_fixtures(
        File.dirname(file),
        File.basename(file, ".yml")
        )
    end
  end
end
