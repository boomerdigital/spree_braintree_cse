braintreeName = (name) ->
  "input[data-braintree-name=#{name}]"

braintreeSelect = (name) ->
  "select[data-braintree-name=#{name}]"

$ ->
  $('form#checkout_form_payment, form#new_payment').submit (event) ->
    if $(this).data('submitting')
      true
    else
      braintreeClient = new braintree.api.Client clientToken: braintree.clientToken
      $(braintreeName "expiration_date").val("#{$(braintreeSelect "expiration_month").val()}/#{$(braintreeSelect "expiration_year").val()}")
      card =
        number: $(braintreeName "number").val()
        expirationDate: $(braintreeName "expiration_date").val().replace(/\s/g, "")
        cvv: $(braintreeName "cvv").val()
        cardholderName: $(braintreeName "cardholder_name").val()

      braintreeClient.tokenizeCard card, (err, nonce) =>
        $(braintreeName "payment_method_nonce").attr('value', nonce)
        $(this).submit()
      $(this).data('submitting', true)
      false
