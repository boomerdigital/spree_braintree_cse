require 'spree_core'
require 'spree_braintree_cse/engine'

Spree::PermittedAttributes.source_attributes.push :device_data
