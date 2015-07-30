Spree::Gateway::BraintreeGateway.class_eval do

  def authorize_with_cse(money, creditcard, options = {})
    if creditcard.gateway_payment_profile_id && !creditcard.gateway_customer_profile_id && preferred_use_client_side_encryption
      payment_method = creditcard.gateway_payment_profile_id
      options[:payment_method_nonce] = true
      provider.authorize(money, payment_method, options)
    else
      authorize_without_cse(money, creditcard, options)
    end
  end

  def method_type
    if preferred_use_client_side_encryption
      "braintree"
    else
      super
    end
  end

  def options_for_payment_with_cse(p)
    if p.source.gateway_customer_profile_id.blank? && p.source.gateway_payment_profile_id.blank? && p.source.encrypted_data.present?
      options = options_for_payment_without_cse(p)
      options.merge!({ payment_method_nonce: p.source.encrypted_data })
    else
      options_for_payment_without_cse(p)
    end
  end

  unless method_defined? :options_for_payment_without_cse
    preference :use_client_side_encryption, :boolean
    alias_method_chain :authorize, :cse
    alias_method_chain :options_for_payment, :cse
  end

end
