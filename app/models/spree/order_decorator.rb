Spree::Order.class_eval do

  module CardSecurityOnVaulting
    # When vaulting a card (i.e. moving from `payment` -> `confirm`) we want to
    # provide the device_data to the records.
    #
    # Unlike the below decoration we cannot just find the payment records and
    # add the info as the payment records don't yet exist (we are creating them
    # via `super`). We cannot find the records and add the info AFTER `super`
    # as the vaulting process happens during `super` (not during `order.next`).
    #
    # This means to give the info to the models we need to modify the params
    # so that it is part of the nested attributes used to create the records.
    def update_from_params params, permitted_params, request_env = {}
      if params[:device_data].present?
        payment_attributes = params[:order][:payments_attributes] if params[:order]
        if payment_attributes && payment_attributes.first
          payment_method_id = payment_attributes.first[:payment_method_id]
          params[:payment_source][payment_method_id][:device_data] = params[:device_data]
        end
      end

      super
    end
  end
  prepend CardSecurityOnVaulting

  module CardSecuirtyOnTransaction
    # When the checkout process moved forward between states it does two things
    #
    # * Updates the order with any info from the request (this method)
    # * Calls `order.next` to transition to the next state
    #
    # Our goal with this decoration is to motify that first step to communicate
    # the device data and 3D-secure data to the models so it is available for
    # the second step to secure the transaction. This information is not saved
    # to the database but just associated with the model in memory. This is
    # enough as the `order.next` uses those same instances.
    #
    # This is really only intended for the `confirm` -> `complete` state but
    # we don't actually check that as it doesn't hurt anything to run it on
    # other transitions and keeps the code simpler by avoiding that check.
    def update_from_params params, permitted_params, request_env = {}
      # Run the standard behavior to update the order with the request info
      ret = super

      # For each payment that might be processed......
      for payment in unprocessed_payments

        # Let the payment know the device data for fraud prevention
        payment.source.device_data = params[:device_data] if params[:device_data].present?

        # Allow the card to be authorized with the secured nonce rather than
        # just the unsecured payment profile token.
        payment.source.encrypted_data = params[:secured_nonce] if params[:secured_nonce].present?
      end

      # Return the original response
      ret
    end
  end
  prepend CardSecuirtyOnTransaction

end
