class LineItemRefundColumns < ActiveRecord::Migration

  def change
    change_table :payment_line_items do |t|
      t.references :administrator, index: true
      t.integer :refund_status, default: 0
    end
  end

end
