require 'digest/md5'

class Spree::Gateway::DotpayController < Spree::BaseController

  skip_before_filter :verify_authenticity_token, :only => [:comeback, :complete]

  def show
    @order = Spree::Order.find(params[:order_id])
    @gateway = @order.available_payment_methods.find{ |x| x.id == params[:gateway_id].to_i }
    @order.payments.destroy_all
    payment = @order.payments.create!(:amount => @order.total, :payment_method_id => @gateway.id)

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("invalid_arguments")
      redirect_to :back
    else
      @bill_address, @ship_address = @order.bill_address, (@order.ship_address || @order.bill_address)
    end
  end

  def comeback
    order   = Spree::Order.find_by(number: params[:control])
    payment = order.payments.last

    payment.update_attribute(:amount, params[:amount])
    # payment.started_processing!

    unless payment.completed?
      case params[:t_status]
      when '1'
        payment.started_processing!
        order.finalize!
      when '3'
        payment.failure!
      when '2'
        payment.complete!
        order.reload
        order.next!
        # order.next!
      else
        fail 'Unexpected payment status'
      end
    end

    render text: 'OK', status: 200
  end

  def complete
    @order = Spree::Order.find_by_number(params[:number])
    session[:order_id] = nil

    if @order.state == "complete"
      redirect_to order_url(@order, {
        :checkout_complete => true,
        :guest_token => @order.guest_token}
      ), :notice => I18n.t('spree.order_processed_successfully')
    else
      redirect_to order_url(@order)
    end
  end

  private

  def dotpay_pl_validate(gateway, params, remote_ip)
    calc_md5 = Digest::MD5.hexdigest(@gateway.preferred_pin + ":" +
      (params[:id].nil? ? "" : params[:id]) + ":" +
      (params[:control].nil? ? "" : params[:control]) + ":" +
      (params[:t_id].nil? ? "" : params[:t_id]) + ":" +
      (params[:amount].nil? ? "" : params[:amount]) + ":" +
      (params[:email].nil? ? "" : params[:email]) + ":" +
      (params[:service].nil? ? "" : params[:service]) + ":" +
      (params[:code].nil? ? "" : params[:code]) + ":" +
      ":" +
      ":" +
      (params[:t_status].nil? ? "" : params[:t_status]))
      md5_valid = (calc_md5 == params[:md5])

      if (remote_ip == @gateway.preferred_dotpay_server_1 || remote_ip == @gateway.preferred_dotpay_server_2) && md5_valid
        valid = true #yes, it is
      else
       valid = false #no, it isn't
      end

      valid
  end

  def dotpay_pl_payment_success(params)
    @order.payment.started_processing
    if @order.total.to_f == params[:amount].to_f
      @order.payment.complete
    end

    @order.finalize!

    @order.next
    @order.next
    @order.save
  end

end