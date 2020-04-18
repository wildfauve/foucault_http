require 'base64'

module FoucaultHttp

  class Net

    extend Dry::Monads::Try::Mixin

    class << self

      # Client interface
      def post
        -> correlation, service, resource, hdrs, enc, body_fn, body {
          HttpPort.post.(correlation, service, resource, hdrs, body_fn, enc, body)
        }.curry
      end

      def delete
        -> correlation, service, resource, hdrs {
          HttpPort.delete.(correlation, service, resource, hdrs)
        }.curry
      end

      # @param service String
      # @param resource String
      # @param hdrs []
      # @param enc String
      # @param query
      # @return Result(NetResponseValue)
      # Example
      # > get.(@env[:host], "/userinfo", {authorization: "Bearer <token> }, :url_encoded, {} )
      def get
        -> correlation, service, resource, hdrs, enc, query {
            HttpPort.get.(correlation, service, resource, hdrs, enc, query)
        }.curry
      end

      # That is, not a circuit breaker
      # @param fn(Llambda)      : A partially applied fn
      # @param args             : The function's arguments as either an array or hash
      # @param retries(Integer) : The max number of retries
      def retryer
        -> fn, args, retries {
          result = fn.(*args)
          return result if result.success?
          return result if retries == 0
          retryer.(fn, args, retries - 1)
        }.curry
      end

      def bearer_token_header
        -> token {
          { authorization: "Bearer #{token}"}
        }
      end
      # (a -> a) -> Hash
      # @param c [String] : Client or user
      # @param s [String] : secret or password
      # @return [Hash{Symbol=>String}]
      def basic_auth_header
        -> c, s {
          { authorization: ("Basic " + Base64::strict_encode64("#{c}:#{s}")).chomp }
        }.curry
      end

      def decode_basic_auth
        -> encoded_auth {
          result = Try { Base64::strict_decode64(encoded_auth.split(/\s+/).last) }
          case result.success?
          when true
            Try { result.value_or.split(":") }
          else
            result
          end
        }
      end

      # @param  Array[Hash]
      # @return [Hash{Symbol=>String}]
      def header_builder
        -> *hdrs { Fn.inject.({}).(Fn.merge).(hdrs) }
      end

      def json_body_fn
        -> body { body.to_json }
      end


    end # class self

  end

end
