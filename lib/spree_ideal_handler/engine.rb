module SpreeIdealHandler
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_ideal_handler'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    initializer "spree.gateway.payment_methods", :after => "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::BillingIntegration::IdealAdvanced
    end

    initializer "spree.spree_ideal_handler.ideal" do |app|
      unless Rails.env.production?
        Ideal::Gateway.environment = :test
      end

      # Other banks preloaded are :abnamro and :rabobank
      Ideal::Gateway.acquirer = :ing 
      Ideal::Gateway.merchant_id = Figaro.env.ideal_merchant_id

      # Maybe you'd like another location
      Ideal::Gateway.passphrase = Figaro.env.ideal_passphrase
      Ideal::Gateway.private_key_file         = File.join(Figaro.env.ideal_keys_path, 'private_key.pem')
      Ideal::Gateway.private_certificate_file = File.join(Figaro.env.ideal_keys_path, 'private_certificate.cer')
      Ideal::Gateway.ideal_certificate_file   = File.join(Figaro.env.ideal_keys_path, 'ideal.cer')

      SpreeIdealHandler::Config = SpreeIdealHandler::Configuration.new
      SpreeIdealHandler::Config[:ideal_confirm_url] = Figaro.env.ideal_confirm_url

    end

    config.to_prepare &method(:activate).to_proc
  end
end
