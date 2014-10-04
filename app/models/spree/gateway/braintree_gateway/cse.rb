module Spree
  class Gateway::BraintreeGateway
    concerning :CSE do
      included do
        preference :use_client_side_encryption, :boolean
      end

      alias_method :authorize, :cse

      def authorize_with_cse(money, creditcard, options = {})
        if creditcard.gateway_payment_profile_id && preferred_use_client_side_encryption
          payment_method = creditcard.gateway_payment_profile_id
          options[:payment_method_nonce] = true
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
    end
  end
end
