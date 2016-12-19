class BraintreePresenter

  def initialize payment_method
    @payment_method = payment_method
    self
  end

  def merchant_account_id(amount)
    if (amount.to_f / 100) >= @payment_method.preferred_account_profile_threshold.to_f
      @payment_method.preferred_above_threshold_account_profile_id
    else
      @payment_method.preferred_merchant_account_id
    end
  end
end
