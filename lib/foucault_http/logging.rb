module FoucaultHttp

  module Logging

    def error(message)
      logger.(:debug, message)
    end

    def debug(message)
      logger.(:debug, message)
    end

    def info(message)
      logger.(:info, message)
    end

    def fatal(message)
      logger.(:fatal, message)
    end

    def logger
      Logger.new
    end

  end

end
