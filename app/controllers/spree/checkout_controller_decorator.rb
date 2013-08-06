Spree::CheckoutController.class_eval do
  def completion_route
    payment = @order.payments.all.find { |payment| payment.payment_method.type == 'Spree::BillingIntegration::IdealAdvanced'}
    
    return spree.order_path(@order) if payment.nil?

    payment.source.payment_redirect_url
  end
end