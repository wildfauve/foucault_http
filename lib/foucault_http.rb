require "foucault_http/version"
require 'dry/monads/result'
require 'dry/monads/maybe'
require 'dry-struct'
require 'dry-types'
require 'dry-configurable'
require 'funcify'

module Types
  include Dry.Types
end

module FoucaultHttp
  require 'foucault_http/logger'
  require 'foucault_http/logging'

  require 'foucault_http/net'
  require 'foucault_http/circuit'
  require 'foucault_http/configuration'
  require 'foucault_http/http_connection'
  require 'foucault_http/http_port'
  require 'foucault_http/net_response_value'
  require 'foucault_http/monad_exception'

  Fn    = Funcify::Fn
  Monad = Funcify::Monad
end
