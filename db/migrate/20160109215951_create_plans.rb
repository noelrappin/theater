class CreatePlans < ActiveRecord::Migration

  def change
    create_table :plans do |t|
      t.string :remote_id
      t.string :plan_name, null: false
      t.integer :price_cents, null: false
      t.string :interval, null: false
      t.integer :tickets_allowed, null: false
      t.string :ticket_category, null: false
      t.integer :status, default: 0
      t.string :description
    end
  end

end
