class CreatePayments < ActiveRecord::Migration

  def change
    create_table :payments do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :price_cents
      t.integer :status
      t.string :reference
      t.string :payment_method
      t.string :response_id
      t.json :full_response
      t.timestamps null: false
    end
  end

end
