Spree::Gateway::BraintreeGateway.class_eval do
  preference :use_client_side_encryption, :boolean

  module CSE
    def authorize money, credit_card, options = {}
      if using_cse? && using_saved_card?(credit_card)
        payment_method = credit_card.gateway_payment_profile_id
        options[:payment_method_nonce] = true
        provider.authorize money, payment_method, options
      else
        super
      end
    end

    def method_type
      if using_cse?
        'braintree'
      else
        super
      end
    end

    def options_for_payment payment
      if payment.source.encrypted_data.present? && no_saved_card?(payment.source)
        super.merge payment_method_nonce: payment.source.encrypted_data
      else
        super
      end
    end

    private

    def no_saved_card? credit_card
      !customer_profile?(credit_card) && !payment_profile?(credit_card)
    end

    def using_saved_card? credit_card
      payment_profile?(credit_card) && !customer_profile?(credit_card)
    end

    def customer_profile? credit_card
      credit_card.gateway_customer_profile_id.present?
    end

    def payment_profile? credit_card
      credit_card.gateway_payment_profile_id.present?
    end

    # A bit less verbose
    def using_cse?
      preferred_use_client_side_encryption
    end
  end
  prepend CSE
end
