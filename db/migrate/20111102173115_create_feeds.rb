class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :stream_id
      t.text :stream_posts

      t.timestamps
    end
  end
end
