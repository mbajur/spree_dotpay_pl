module Spree
  class DotpayCallbacksController < BaseController
    protect_from_forgery :except => [:create]
    skip_before_filter :restriction_access

    def create
      order   = Spree::Order.find_by(number: params[:control])
      payment = order.payments.last

      payment.started_processing!

      unless payment.completed?
        case params[:t_status]
        when '1', '3'
          payment.failure!
        when '2'
          payment.complete!
          order.next
        else
          fail "Unexpected payment status"
        end
      end

      render text: 'OK', status: 200
    end
  end
end
