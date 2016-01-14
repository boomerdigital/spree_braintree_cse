Spree::Gateway::BraintreeGateway.class_eval do
  preference :use_client_side_encryption, :boolean

  module CSE
    def authorize money, creditcard, options = {}
      if creditcard.gateway_payment_profile_id && !creditcard.gateway_customer_profile_id && preferred_use_client_side_encryption
        payment_method = creditcard.gateway_payment_profile_id
        options[:payment_method_nonce] = true
        provider.authorize money, payment_method, options
      else
        super
      end
    end

    def method_type
      if preferred_use_client_side_encryption
        'braintree'
      else
        super
      end
    end

    def options_for_payment payment
      if payment.source.gateway_customer_profile_id.blank? && payment.source.gateway_payment_profile_id.blank? && payment.source.encrypted_data.present?
        super.merge payment_method_nonce: payment.source.encrypted_data
      else
        super
      end
    end
  end
  prepend CSE
end
