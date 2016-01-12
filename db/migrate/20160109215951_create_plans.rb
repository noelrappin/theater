class CreatePlans < ActiveRecord::Migration

  def change
    create_table :plans do |t|
      t.string :remote_id, null: false
      t.string :plan_name, null: false
      t.integer :amount_cents, null: false
      t.string :interval, null: false
      t.integer :tickets_allowed, null: false
      t.string :ticket_category, null: false
    end
  end

end
