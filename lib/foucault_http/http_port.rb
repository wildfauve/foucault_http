module FoucaultHttp

  class HttpPort

    class NoContentTypeError < StandardError; end

    extend Dry::Monads::Try::Mixin
    extend Logging

    FAIL                 = :fail
    OK                   = :ok
    BAD_REQUEST          = :bad_request
    UNAUTHORISED         = :unauthorised
    NOT_FOUND            = :not_found
    SYSTEM_FAILURE       = :system_failure
    UNPROCESSABLE_ENTITY = :unprocessable_entity

    class << self

      def post
        -> correlation, service, resource, opts, hdrs, body_fn, enc, body {
          ( Fn.either.(net_ok).(Monad.success).(Monad.failure) <<
            log_response.(correlation, service, resource, __method__) <<
            response_value <<
            run_post.(hdrs, body_fn, body) <<
            addressed.(service, resource)).(connection.(opts, enc))
        }
      end

      def get
        -> correlation, service, resource, opts, hdrs, enc, query {
          ( Fn.either.(net_ok).(Monad.success).(Monad.failure) <<
            log_response.(correlation, service, resource, __method__) <<
            response_value <<
            run_get.(hdrs, query) <<
            addressed.(service, resource)).(connection.(opts, enc))
        }
      end

      def delete
        -> correlation, service, resource, opts, hdrs {
          ( Fn.either.(net_ok).(Monad.success).(Monad.failure) <<
            log_response.([], service, resource, __method__) <<
            response_value <<
            run_delete.(hdrs) <<
            addressed.(service, resource)).(connection.(opts, nil))
        }
      end


      def run_post
        -> hdrs, body_fn, body, connection {
          connection.post(hdrs, Try { body_fn.(body) })
        }.curry
      end

      def run_get
        -> hdrs, query, connection {
          connection.get(hdrs, query)
        }.curry
      end

      def run_delete
        -> hdrs, connection {
          connection.delete(hdrs)
        }.curry
      end

      def addressed
        -> service, resource, connection {
          connection.(address.(service, resource))
        }.curry
      end

      def connection
        -> opts, encoding, address { HttpConnection.new.connection(address, opts, encoding) }.curry
      end

      def address
        -> service, resource {
          (service || "") + (resource || "")
        }.curry
      end

      def response_value
        -> response {
          response.success? ? try_handle_response(response) : catastrophic_failure(response)
        }
      end

      def log_response
        -> correlation, service, resource, api, response {
          info(structured_log(service, resource, api, response, correlation))
          response
        }.curry
      end

      def try_handle_response(response)
        result = Try { returned_response(response) }
        result.success? ? result.value_or : catastrophic_failure(result)
      end

      def evalulate_status
        -> status {
          case status
          when 200..300
            OK
          when 400
            BAD_REQUEST
          when 401, 403
            UNAUTHORISED
          when 404
            NOT_FOUND
          when 422
            UNPROCESSABLE_ENTITY
          when 500..530
            SYSTEM_FAILURE
          else
            FAIL
          end
        }
      end

      # takes a content type and returns a parser; e.g. "application/json; charset=utf-8" returns the json_parser
      def response_body_parser
        parser_fn <<
        Fn.at.(0) <<
        Fn.split.(";")
      end

      def parser_fn
        -> type {
          case type
          when "text/html"
            xml_parser
          when "text/plain"
            text_parser
          when "text/csv"
            text_parser
          when "application/json"
            json_parser
          when "application/xml", "application/soap+xml", "text/xml"
            xml_parser
          else
            nil_parser
          end
        }
      end

      def returned_response(response)
        raise(NoContentTypeError.new("Content Type in response is nil")) unless response.value_or.headers["content-type"]
        OpenStruct.new(
          status: evalulate_status.(response.value_or.status),
          code: response.value_or.status,
          body: response_body_parser.(response.value_or.headers["content-type"]).(response.value_or)
        )
      end

      def catastrophic_failure(response)
        OpenStruct.new(
          status: SYSTEM_FAILURE,
          exception: parse_error_response(response),
          code: 418
        )
      end

      def parse_error_response(response)
        result = response.to_result
        if result.failure.respond_to?(:exception)
          {exception_class: result.failure.exception.class.name, exception: result.failure.message}
        else
          {execepton: "not-determined"}
        end
      end

      def json_parser
        -> response { JSON.parse(response.body) }
      end

      def xml_parser
        -> response { Nokogiri::XML(response.body) }
      end

      def text_parser
        -> response { response.body }
      end

      def text_csv
        -> response { response.body }
      end

      def nil_parser
        -> response { response.body }
      end

      def net_ok
        -> value { value.status == OK }
      end

      def structured_log(service, resource, api, response, correlation={})
        {
          msg: "Common::Network::Net",
          context: context_for_log(service, resource, response, correlation),
          step: api,
          status: response.status
        }
      end

      def context_for_log(service, resource, response, correlation={})
        {
          http_code: response.code,
          resource: address.(service, resource),
          fail_response: log_of_failure(response)
        }.merge(correlation || {})
      end

      def log_of_failure(response)
        return nil if net_ok.(response)
        response.body.inspect
      end

    end

  end

end
