require "singleton"
require "logger"

class Log
  attr_accessor :logger
  include Singleton

  def initialize
    @logger = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
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

  def self.missingClassRef(clsRef)
    instance.logger.error("Missing class ref cname: " + clsRef.className + "  plugin: " + clsRef.pluginName)
  end
end
