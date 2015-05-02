class InitialSchema < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.references :recreation, index: true
      t.integer :tweet_id, index: true, limit: 8
      t.string :screen_name
      t.text :text
      t.timestamps null: false
    end

    create_table :recreations do |t|
      t.string :name, index: true
      t.timestamps null: false
    end
  end
end
