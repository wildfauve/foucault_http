require 'faraday'
require 'typhoeus'
module FoucaultHttp

  class HttpConnection

    include Dry::Monads::Try::Mixin
    include Dry::Monads::Result::Mixin

    HTTP_CONNECTION_FAILURE = :http_connection_failure

    def connection(address, encoding, cache_store = nil, instrumenter = nil)
      @http_connection = Try { http_connection(address, encoding, cache_store, instrumenter) }
      self
    end

    def get(hdrs, params)
      return @http_connection.to_result if @http_connection.failure?
      Try {
        @http_connection.value_or.get do |r|
          r.headers = hdrs if hdrs
          r.params = params if params
        end
      }.to_result
    end

    def post(hdrs, body)
      return @http_connection.to_result if @http_connection.failure?
      Try {
        @http_connection.value_or.post do |r|
          r.body = body
          r.headers = hdrs
        end
      }.to_result
    end

    def delete(hdrs)
      return @http_connection.to_result if @http_connection.failure?
      Try {
        @http_connection.value_or.delete do |r|
          r.headers = hdrs
        end
      }.to_result
    end

    private

    def http_connection(address, encoding, cache_store, instrumenter)
      faraday_connection = Faraday.new(:url => address) do |faraday|
        # faraday.use :http_cache, caching if caching
        faraday.request  encoding if encoding
        if Configuration.config.logger && Configuration.config.log_formatter
          faraday.response :logger, Configuration.config.logger, formatter: Configuration.config.log_formatter
        elsif Configuration.config.logger
          faraday.response :logger, Configuration.config.logger
        else
          faraday.response :logger do |log|
            log.filter(/(Bearer.)(.+)/, '\1[REMOVED]')
            log.filter(/(Basic.)(.+)/, '\1[REMOVED]')
          end
        end
        faraday.adapter  :typhoeus
      end
      faraday_connection
    end

  end

end
