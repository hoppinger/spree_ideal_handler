module Spree
  class BillingIntegration::IdealAdvanced < BillingIntegration

    # preference :merchant_id, :string
    # preference :language, :string, :default => 'EN'
    # preference :currency, :string, :default => 'EUR'
    # preference :payment_options, :string, :default => 'ACC'
    # preference :pay_to_email, :string ,   :default => 'your@merchant.email_here' 

    # attr_accessible :preferred_merchant_id, :preferred_language, :preferred_currency,
    #                 :preferred_payment_options, :preferred_server, :preferred_test_mode,
    #                 :preferred_pay_to_email

    def payment_source_class
      IdealPayment
    end

    def bank_list
      Ideal::Gateway.new.issuers.list
    end

    def authorize(amount, source, gateway_options)
      source.authorize(self, amount, gateway_options)
    end
    def purchase(amount, source, gateway_options)
      source.purchase(self, amount, gateway_options)
    end
  end

end