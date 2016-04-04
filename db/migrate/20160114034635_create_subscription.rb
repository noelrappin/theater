class CreateSubscription < ActiveRecord::Migration

  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :plan
      t.date :start_date
      t.date :end_date
      t.integer :status
      t.string :payment_method
      t.string :remote_id
      t.timestamps
    end
  end

end
