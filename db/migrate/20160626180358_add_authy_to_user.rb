class AddAuthyToUser < ActiveRecord::Migration

  def change
    change_table :users do |t|
      t.string :authy_id
    end
  end

end
