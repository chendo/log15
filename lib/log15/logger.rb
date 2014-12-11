require 'logger'
require 'json'

module Log15
  class Logger
    attr_accessor :logger
    def initialize(logger=Rails.logger)
      @logger = logger.dup
      @logger.formatter = proc do |severity, datetime, progname, msg|
        date = "#{datetime.month}-#{datetime.day}"
        time = "#{pad(datetime.hour)}:#{pad(datetime.min)}:#{pad(datetime.sec)}"
        severities = { "ERROR" => "EROR", "DEBUG" => "DBUG" }
        original_severity = severity
        severity = severities.fetch(severity, severity)
        "#{severity}[#{date}|#{time}] #{msg} lvl=#{original_severity.downcase}\n"
      end
    end

    def self.default
      @logger ||= Log15::Logger.new
    end

    def self.sanitize(params, key, opts={})
      if params[key]
        raise SanitizationError, "expected #{key} to not be blank" if params[key] == ""
        if opts[:expected_length]
          minimum_size = opts[:expected_length].first
          maximum_size = opts[:expected_length].last
          length = params[key].length
          if length < minimum_size || length > maximum_size
            raise SanitizationError, "expected access_token to be between #{minimum_size} and #{maximum_size} characters long (is #{length})"
          end
        end
        params[key] = params[key][0..5] + "****" + params[key][-6..-1]
      else
        raise SanitizationError, "expected #{key} to be present"
      end
      params
    end

    def debug(msg, data={})
      logger.debug(process(msg, data))
    end

    def info(msg, data={})
      logger.info(process(msg, data))
    end

    def warn(msg, data={})
      logger.warn(process(msg, data))
    end

    def error(msg, data={})
      logger.error(process(msg, data))
    end

    private

    def process(msg, data)
      output = ["#{msg}"]
      if data.keys.count > 0
        data.each do |k, v|
          if v.is_a?(Array) || v.is_a?(Hash)
            output << ["#{k}=#{JSON.dump(v).inspect}"]
          else
            output << ["#{k}=#{v.inspect}"]
          end
        end
      end

      output.join(" ")
    end

    def pad(number)
      number.to_s.rjust(2, '0')
    end
  end
end
