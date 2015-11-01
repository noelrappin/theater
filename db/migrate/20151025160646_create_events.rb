class CreateEvents < ActiveRecord::Migration

  def change
    create_table :events do |t|
      t.string :name
      t.text :description
      t.string :image_url

      t.timestamps null: false
    end
  end

end
