class AddExpiresAtToIdealPayments < ActiveRecord::Migration
  def up
    add_column :spree_ideal_payments, :expires_at, :datetime
  end

  def down
    remove_column :spree_ideal_payments, :expires_at
  end
end
