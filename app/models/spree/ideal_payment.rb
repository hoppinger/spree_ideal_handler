module Spree
  class IdealPayment < ActiveRecord::Base
    include Spree::Core::Engine.routes.url_helpers

    attr_accessible :bank_id, :transaction_id, :payment_redirect_url, :entrance_code
    has_many :payments, :as => :source

    state_machine initial: :open do
      event :expire do
        transition from: [:open], to: :expired
      end
      event :fail do
        transition from: [:open], to: :failure
      end
      event :cancel do
        transition from: [:open], to: :cancelled
      end
      event :succeed do
        transition from: [:open], to: :success
      end

      after_transition any => [:expired, :failure, :cancelled] do |ideal_payment, transition|
        ideal_payment.first_payment.failure!
      end
      after_transition any => :success do |ideal_payment, transition|
        ideal_payment.first_payment.complete!
      end
    end

    scope :needs_checking, -> { where(state: 'open').where('expires_at < :now', now: Time.now) }


    def self.update_states
      self.needs_checking.map(&:update_state)
    end

    def update_state
      raise unless open? 

      response = Ideal::Gateway.new.capture(self.transaction_id)
      
      path = self.state_paths(to: response.status).first
      raise if path.nil?

      path.map(&:perform)
    end

    def is_payed?
      response = Ideal::Gateway.new.capture(self.transaction_id)
      response.status == :success
    end

    def first_payment
      self.payments.first
    end
    
    def authorize(payment_method, amount, options)
      payment = self.payments.first
      order = payment.order

      entrance_code = generate_entrance_code
      
      response = Ideal::Gateway.new.setup_purchase(amount, {
        return_url: SpreeIdealHandler::Config[:ideal_confirm_url],
        issuer_id: bank_id,
        order_id: order.number,
        expiration_period: "PT30M", # 30 minutes
        description: order.number,
        entrance_code: entrance_code,
      })

      if response.success?
        self.transaction_id = response.transaction_id
        self.payment_redirect_url = response.service_url
        self.entrance_code = entrance_code
        self.expires_at = Time.now + 30*60 + 100 # 30 minutes and some margin
        self.save

        return ActiveMerchant::Billing::Response.new(true, "")
      end

      self.save
      ActiveMerchant::Billing::Response.new(false, "Could not setup purchase.")
    end

    def purchase(payment_method, amount, options)
      return ActiveMerchant::Billing::Response.new(true, "")
    end
    
    # fix for Payment#payment_profiles_supported?
    def payment_gateway
      false
    end

    private

    def generate_entrance_code
      chars = [('A'..'Z').to_a, ('0'..'9').to_a].flatten
      entrance_code = ''
      40.times { entrance_code << chars[rand(chars.length)] }

      entrance_code
    end
    
  end
end