class AddEntranceCodeToIdealPayments < ActiveRecord::Migration
  def up
    add_column :spree_ideal_payments, :entrance_code, :string
  end

  def down
    remove_column :spree_ideal_payments, :entrance_code
  end
end
