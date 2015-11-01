class CreateTickets < ActiveRecord::Migration

  def change
    create_table :tickets do |t|
      t.references :user, index: true, foreign_key: true
      t.references :performance, index: true, foreign_key: true
      t.integer :status
      t.integer :access
      t.integer :price_cents

      t.timestamps null: false
    end
  end

end
