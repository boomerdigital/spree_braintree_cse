class Braintree::PaymentMethodNoncesController < ApplicationController

  def create
    render text: Braintree::PaymentMethodNonce.create(params[:payment_method_id]).payment_method_nonce.nonce
  end

end
