class Sessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :sessid
      t.integer :user_id
    end
  end
end
