class AddAdminColumn < ActiveRecord::Migration

  def change
    change_table :payments do |t|
      t.references :administrator, index: true
    end
  end

end
