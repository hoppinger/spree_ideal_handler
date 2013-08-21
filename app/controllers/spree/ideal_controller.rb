module Spree
  class IdealController < Spree::StoreController
    protect_from_forgery :except => [:confirm]

    def confirm
      transaction_id = params[:trxid]
      entrance_code = params[:ec]

      ideal_payment = IdealPayment.where(transaction_id: transaction_id, entrance_code: entrance_code).first
      return redirect_to root_path if ideal_payment.nil?

      payment = ideal_payment.payments.first
      return redirect_to root_path if payment.nil?

      order = payment.order
      return redirect_to root_path if order.nil?

      if order.payment_state == 'paid'
        flash[:commerce_tracking] = I18n.t("notice_messages.track_me_in_GA")
        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        return redirect_to order_url(order, {:checkout_complete => true, :order_token => order.token})
      end

      unless ideal_payment.open? || ideal_payment.success?
        flash[:error] = "iDEAL betaling is niet gelukt of afgebroken. U kunt de bestelling via een bankoverschrijving voldoen."
        session[:order_id] = nil
        return redirect_to order_url(order)
      end

      begin
        ideal_payment.update_state
      rescue; end
      
      unless ideal_payment.success?
        flash[:error] = "iDEAL betaling is niet gelukt of afgebroken. U kunt de bestelling via een bankoverschrijving voldoen."
        session[:order_id] = nil
        return redirect_to order_url(order)
      end

      flash[:commerce_tracking] = I18n.t("notice_messages.track_me_in_GA")
      session[:order_id] = nil
      flash.notice = Spree.t(:order_processed_successfully)
      redirect_to order_url(order, {:checkout_complete => true, :order_token => order.token})
    end
  end
end