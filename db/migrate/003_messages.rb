class Messages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message
      t.integer :user_id
    end
  end
end
