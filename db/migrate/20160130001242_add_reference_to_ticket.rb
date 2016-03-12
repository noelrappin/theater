class AddReferenceToTicket < ActiveRecord::Migration

  def change
    add_column :tickets, :payment_reference, :string
  end

end
