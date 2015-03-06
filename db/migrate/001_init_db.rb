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
  end
end
