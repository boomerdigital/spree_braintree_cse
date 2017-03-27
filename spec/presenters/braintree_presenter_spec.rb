require 'spec_helper'

describe "BraintreePresenter"
  subject do
    braintree_payment_method = Spree::Gateway::BraintreeGateway.new(
      name: 'Credit Card',
      active: true
    )
    braintree_payment_method = {
      environment: 'sandbox',
      merchant_id: 'q65fd2m8p2xx8jc5',
      merchant_account_id: 'magpie_2',
      public_key: 'kxw7sndxmb73hzxx',
      private_key: 'e476d8e57b39e3f54b8f64fb503132d1',
      client_side_encryption_key: 'MIIBCgKCAQEAt1qVwMfuz7sN/e46WM+xE724/r0XHDpRViptdUJ8PayS/uP+66Q4GCLJOQEFXPLRalOAdxfbZBr9JIQ9d9SSKhcNkvegS7wcJ4+C28QzRugs+K6kpEh3aHddA1sVEcoPTVVaodzTfYBplqp2UH3EHUW5H+HCDobq5t7jSurQUoj5rRg4I4ehmpYiqBB8Y1WL2Sm5WtyOu2Eo6aAAFkPHlN6NFO7spxOSf5rrFK6h5dD5yVdT3oGcvNXgHlSKQ8SdSN5TTY5lZthN4ImwElH5c7kwbTPG61tYd7lJ1KMqV4Fg07RJiRdLzB0vOpvmXx9rYKSy5qM/ub2pz2Hnlm2cKQIDAQAB',
      use_client_side_encryption: true,
      three_d_threshold: 10,
      countries_of_issuance: '',
      server: 'test',
      test_mode: true,
      account_profile_threshold: 5,
      above_threshold_account_profile_id: 'magpie_3'
    }
  end

  let(:presenter) { described_class.new(braintree_payment_method) }

  describe '#merchant_account_id'
    it "selects merchant account below threshold" do
      response = presenter.merchant_account_id(4.99)
      expect(response).to eq('magpie_2')
    end

    it "selects merchant account above threshold" do
      response = presenter.merchant_account_id(5.01)
      expect(response).to eq('magpie_3')
    end
  end
end
