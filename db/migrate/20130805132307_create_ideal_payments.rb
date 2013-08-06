class CreateIdealPayments < ActiveRecord::Migration
  def change
    create_table :spree_ideal_payments do |t|
      t.string :bank_id
      t.string :transaction_id
      t.string :payment_redirect_url
      
      t.timestamps
    end
  end
end
