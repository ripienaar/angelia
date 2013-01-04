require'rubygems'
require 'httparty'
require 'json'

module Angelia::Plugin
  # Plugin to deliver push notifications to Opsgenie, the subject will be
  # used as the entity
  #
  # You need to sign up for with opsgenie and configure the plugin:
  #
  # plugin = Opsgenie
  # plugin.Opsgenie.apikey = xxx
  #
  # You can then send messages to users people using opsgenie://you@example.com
  class Boxcar
    def initialize(config)
      Angelia::Util.debug("Creating new insance of Opsgenie plugin")

      @config = config
      @endpoint = "https://api.opsgenie.com/v1/json/alert"
      @lastfailure = 0
    end

    def self.register
      Angelia::Util.register_plugin("opsgenie", "Opsgenie")
    end

    def send(recipient, subject, msg)
      Angelia::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")

      apikey = @config["apikey"]

      begin
        resp = HTTParty.post(@endpoint, {:body => {"customerKey" => apikey, :message => msg, :recipients => recipient, :entity => subject}.to_json})

        if resp.code == 200
          return 0
        else
          raise(Angelia::PluginConnectionError, "Could not send message, api code: #{resp.code}: %s" % resp.parsed_response)
        end
      rescue Exception => e
        raise(Angelia::PluginConnectionError, "Unhandled issue sending alert: #{e}")
      end
    end
  end
end
