class CreateDiscountCodes < ActiveRecord::Migration
  def change
    create_table :discount_codes do |t|
      t.string :code
      t.integer :percentage
      t.text :description
      t.integer :min_amount_cents
      t.integer :max_discount_cents
      t.integer :max_uses

      t.timestamps null: false
    end

    change_table :payments do |t|
      t.references :discount_code
      t.integer :discount_cents
    end
    
  end
end
