Spree::Gateway::BraintreeGateway.class_eval do
  preference :use_client_side_encryption, :boolean
  preference :three_d_threshold, :integer, default: 10
  preference :account_profile_threshold, :integer, default: 5
  preference :above_threshold_account_profile_id, :string

  module Extensions
    refine Hash do
      # Will merge all key/value pairs where the value is populated
      def merge_populated! other

        debugger

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

      debugger

      if preferred_use_client_side_encryption
        'braintree'
      else
        super
      end
    end

    # When creating a profile for a new card to pass on the encrypted card info
    def options_for_payment payment

      debugger

      super.merge_populated payment_method_nonce: payment.source.encrypted_data
    end
  end
  prepend CSE

  module CardSecurity
    def authorize money, credit_card, options={}
      # Include device data if present

      debugger

      options[:device_data] = credit_card.device_data
      options[:merchant_account_id] = merchant_account_id credit_card.payment_method, money

      if (money.to_f / 100) >= credit_card.payment_method.preferred_three_d_threshold
        # Is expensive enough that three_d_secure should be used
        options[:payment_method_nonce] = true
        options[:three_d_secure] = { required: true }

        adjust_options_for_braintree credit_card, options
        provider.authorize money, credit_card.encrypted_data, options
      else
        # Use normal implementation
        super
      end
    end

    # Adds device data when storing new card to prevent fraud
    def options_for_payment payment

      debugger

      super.merge_populated \
        device_data: payment.source.device_data,
        verification_merchant_account_id: merchant_account_id(payment.payment_method, payment.amount.to_f * 100)
    end

    private

    def merchant_account_id payment_method, amount
      BraintreePresenter.new(payment_method).merchant_account_id(amount)
    end
  end
  prepend CardSecurity
end
