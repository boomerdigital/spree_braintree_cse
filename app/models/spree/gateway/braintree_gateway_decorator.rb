Spree::Gateway::BraintreeGateway.class_eval do
  preference :use_client_side_encryption, :boolean
  preference :three_d_threshold, :integer, default: 10

  module Extensions
    refine Hash do
      # Will merge all key/value pairs where the value is populated
      def merge_populated! other
        other.each do |key, value|
          self[key] = value if value.present?
        end
        self
      end

      # Same as merge_populated! but non-destructive
      def merge_populated other
        dup.merge_populated! other
      end
    end
  end
  using Extensions

  module CSE
    # Controls what template is rendered accept input of a new card. In general
    # all gateways share the same template just called `gateway` but we need a
    # special template just for Braintree to contain the special encrypted_data,
    # device_data and nonce information.
    def method_type
      if preferred_use_client_side_encryption
        'braintree'
      else
        super
      end
    end

    # When creating a profile for a new card to pass on the encrypted card info
    def options_for_payment payment
      super.merge_populated payment_method_nonce: payment.source.encrypted_data
    end
  end
  prepend CSE

  module CardSecurity
    # Actually carries out the authorization of a purchase. This enforces the
    # 3D Secure functionality and reads the relevant data from the card.
    # Also copies device data for fraud protection.
    def authorize money, credit_card, options={}
      options[:device_data] = credit_card.device_data
      options.merge! three_d_secure: {required: true},
        payment_method_nonce: credit_card.encrypted_data if
        money >= credit_card.payment_method.preferred_three_d_threshold

      super money, credit_card, options
    end

    # Adds device data when storing new card to prevent fraud
    def options_for_payment payment
      super.merge_populated device_data: payment.source.device_data
    end
  end
  prepend CardSecurity
end
