class CreateSubscription < ActiveRecord::Migration

  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :plan
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.timestamps
    end
  end

end
