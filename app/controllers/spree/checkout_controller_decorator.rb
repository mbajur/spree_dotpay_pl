Spree::CheckoutController.class_eval do

  before_filter :pay_with_dotpay, only: :update

  private

  def pay_with_dotpay
    return unless params[:state] == "payment"

    @payment_method = Spree::PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
    if @payment_method && @payment_method.kind_of?(Spree::BillingIntegration::DotpayPl)
      redirect_to(gateway_dotpay_path(gateway_id: @payment_method.id, order_id: @order.id)) and return false
    end
  end

end