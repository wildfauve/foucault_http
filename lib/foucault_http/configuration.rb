module FoucaultHttp

  class Configuration

    extend Dry::Configurable

    setting :type_parsers, {}
    setting :logger
    setting :log_formatter
    setting :network_log_formatter
    setting :logging_level

  end  # class Configuration

end  # module ScoreCard
