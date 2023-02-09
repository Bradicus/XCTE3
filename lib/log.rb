require "singleton"
require "logger"

class Log
  attr_accessor :logger
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    #@logger.level = Logger::INFO
  end

  def self.info(msg)
    instance.logger.info(msg)
  end

  def self.debug(msg)
    instance.logger.debug(msg)
  end

  def self.warn(msg)
    instance.logger.warn(msg)
  end

  def self.error(msg)
    instance.logger.error(msg)
  end
end
