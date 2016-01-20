Spree::Order.class_eval do

  module CardSecurity
    # Decorate how Spree processes the payment checkout form so that the card
    # security information is communicated to the card. The model level uses
    # this data to pass it onto braintree.
    def update_from_params params, permitted_params, request_env = {}
      # Run the standard behavior
      success = super

      # For each payment that might be processed......
      for payment in unprocessed_payments

        # Let the payment know the device data for fraud prevention when
        # actually processing the card. We already did this if we created a
        # card but if we are using a saved card we need to do to do it here also
        payment.source.device_data = params[:device_data] if params[:device_data].present?

        # So that the card is authorized with the secured nonce rather than just
        # the unsecured payment profile token.
        payment.source.encrypted_data = params[:secured_nonce] if params[:secured_nonce].present?
      end

      success
    end

  end
  prepend CardSecurity

end
