class AddStateToIdealPayments < ActiveRecord::Migration
  def up
    add_column :spree_ideal_payments, :state, :string
  end

  def down
    remove_column :spree_ideal_payments, :state
  end
end
