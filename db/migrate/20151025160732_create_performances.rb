class CreatePerformances < ActiveRecord::Migration

  def change
    create_table :performances do |t|
      t.references :event, index: true, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps null: false
    end
  end

end
