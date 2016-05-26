class AddRefundColumns < ActiveRecord::Migration

  def change
    change_table :payments do |t|
      t.references :original_payment, index: true
    end

    change_table :payment_line_items do |t|
      t.references :original_line_item, index: true
    end
  end

end
