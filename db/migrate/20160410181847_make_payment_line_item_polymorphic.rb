class MakePaymentLineItemPolymorphic < ActiveRecord::Migration

  def change
    rename_column :payment_line_items, :ticket_id, :reference_id
    add_column :payment_line_items, :reference_type, :string
  end

end
