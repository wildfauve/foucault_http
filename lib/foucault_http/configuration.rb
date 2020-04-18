module FoucaultHttp

  class Configuration

    # DEFAULT_SERVICE_DISCOVERY = FakeServiceDiscovery
    # DEFAULT_CACHE_STORE = HttpCache.new

    extend Dry::Configurable

    # setting :cache_store, DEFAULT_CACHE_STORE
    # setting :service_discovery, DEFAULT_SERVICE_DISCOVERY
    setting :type_parsers, {}
    setting :kafka_client_id
    setting :zookeeper_broker_list
    setting :kafka_broker_list
    setting :logger
    setting :log_formatter
    setting :logging_level

  end  # class Configuration

end  # module ScoreCard
