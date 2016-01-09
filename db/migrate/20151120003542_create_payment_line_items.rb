class CreatePaymentLineItems < ActiveRecord::Migration

  def change
    create_table :payment_line_items do |t|
      t.references :payment, index: true, foreign_key: true
      t.references :ticket, index: true, foreign_key: true
      t.integer :price_cents
      t.timestamps null: false
    end
  end

end
