$ = jQuery

cc_fld = (scope, name) -> scope.find "input[data-braintree-name=#{name}]"
cc_val = (scope, name) -> cc_fld(scope, name).val()

payment_form = 'form#checkout_form_payment'

$ ->
  payment_forms = $ payment_form
  return if payment_forms.length == 0
  collector = braintree.data.setup kount: {environment: braintree.environment}
  cc_fld(payment_forms, 'device_data').val collector.deviceData
  collector.teardown()

$(document).on 'submit', payment_form, (event) ->
  $_ = $ @
  return if $_.data 'submitting'

  processor = new braintree.api.Client clientToken: braintree.clientToken
  card =
    number: cc_val $_, "number"
    expirationDate: cc_val($_, "expiration_date").replace /\s/g, ""
    cvv: cc_val $_, "cvv"
    cardholderName: cc_val $_, "cardholder_name"

  processor.tokenizeCard card, (err, nonce) ->
    cc_fld($_, 'payment_method_nonce').val nonce
    $_.submit()

  $_.data 'submitting', true
  event.preventDefault()
