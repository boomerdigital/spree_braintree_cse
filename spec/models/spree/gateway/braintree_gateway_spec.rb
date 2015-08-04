require 'spec_helper'

module Spree
  class Gateway
    RSpec.describe BraintreeGateway, '#authorize_with_cse' do
      subject do
        gateway = described_class.new(
          name: 'Braintree Gateway',
          active: true
        )
        gateway.preferences = {
          environment: 'sandbox',
          merchant_id: 'zbn5yzq9t7wmwx42',
          public_key: 'ym9djwqpkxbv3xzt',
          private_key: '4ghghkyp2yy6yqc8'
        }

        gateway
      end

      let(:credit_card) do
        build(
          :credit_card,
          verification_value: '123',
          number: '5555555555554444',
          month: 9,
          year: Time.now.year + 1,
          name: 'John Doe',
          cc_type: 'mastercard',
          gateway_payment_profile_id: 'test'
        )
      end

      context 'when use_client_side_encryption is enabled' do
        before do
          subject.set_preference(:use_client_side_encryption, true)
        end

        it 'calls provider#authorize using payment_method_nonce' do
          allow(subject.provider).to receive(:authorize)

          subject.authorize(500, credit_card)

          expect(subject.provider).to have_received(:authorize).
            with(500, 'test', { payment_method_nonce: true } )
        end
      end

      context 'when use_client_side_encryption is disabled' do
        before do
          subject.set_preference(:use_client_side_encryption, false)
        end

        it 'calls provider#authorize using payment_method_nonce' do
          credit_card.update_attributes(gateway_payment_profile_id: 'test')
          allow(subject.provider).to receive(:authorize)

          subject.authorize(500, credit_card)

          expect(subject.provider).to have_received(:authorize).
            with(500, 'test', { payment_method_token: true } )
        end
      end
    end

    RSpec.describe BraintreeGateway, '#method_type' do
      context 'when use_client_side_encryption is enabled' do
        it 'responds with "braintree"' do
          subject.set_preference(:use_client_side_encryption, true)

          expect(subject.method_type).to eq 'braintree'
        end
      end

      context 'when use_client_side_encryption is disabled' do
        it 'responds with "gateway"' do
          subject.set_preference(:use_client_side_encryption, false)

          expect(subject.method_type).to eq 'gateway'
        end
      end
    end

    RSpec.describe BraintreeGateway, '#options_for_payment' do
      let(:country) do
        build(
          :country,
          name: 'United States',
          iso_name: 'UNITED STATES',
          iso3: 'USA',
          iso: 'US',
          numcode: 840
        )
      end

      let(:address) do
        build(
          :address,
          firstname: 'John',
          lastname: 'Doe',
          address1: '1234 My Street',
          address2: 'Apt 1',
          city: 'Washington DC',
          zipcode: '20123',
          phone: '(555)555-5555',
          company: nil,
          state: nil,
          state_name: 'AnyState',
          country: country
        )
      end

      let(:payment) do
        double(
          Spree::Payment,
          order: order,
          number: "P1566",
          currency: "EUR",
          payment_method: double,
          source: source
        )
      end

      let(:source) do
        double(
          'FakeSource',
          encrypted_data: 'encrypted_nonce',
          gateway_customer_profile_id: '',
          gateway_payment_profile_id: ''
        )
      end

      let(:order) do
        double(Spree::Order, email: 'bob@farva.com', bill_address: address)
      end

      context 'when encrypted_data is nil' do
        it 'does not add payment_method_nonce to options hash' do
          allow(source).to receive(:encrypted_data) { nil }

          expect(subject.send(:options_for_payment, payment)).to match(
            billing_address: {
              address1: address.address1,
              address2: address.address2,
              company: address.company,
              city: address.city,
              state: address.state_name,
              country_code_alpha3: 'USA',
              zip: address.zipcode
            },
            email: order.email,
            first_name: address.firstname,
            last_name: address.lastname,
            verify_card: 'true'
          )
        end
      end

      context 'when encrypted_data is available' do
        it 'merges in the payment_method_nonce hash' do
          allow(source).to receive(:encrypted_data) { 'testing_code' }

          expect(subject.send(:options_for_payment, payment)).to match(
            billing_address: {
              address1: address.address1,
              address2: address.address2,
              company: address.company,
              city: address.city,
              state: address.state_name,
              country_code_alpha3: 'USA',
              zip: address.zipcode
            },
            email: order.email,
            first_name: address.firstname,
            last_name: address.lastname,
            payment_method_nonce: 'testing_code',
            verify_card: 'true'
          )
        end
      end
    end
  end
end
