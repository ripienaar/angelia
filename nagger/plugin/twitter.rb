require 'timeout'

module Nagger::Plugin
    class Twitter
        def initialize(config)
            Nagger::Util.debug("Creating new insance of Twitter plugin")

            @config = config
            @lastfailure = 0
        end

        def self.register
            Nagger::Util.register_plugin("twitter", "Twitter")
        end

        def send(recipient, subject, msg)
            Nagger::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")

            user = @config["username"]
            password = @config["password"]
            url = @config["url"]

            # if we had a failed delivery in the last 10 minutes do not try to send a new message
            # this is just to prevent us spamming twitter and getting in their bad books
            if Time.now.to_i - @lastfailure.to_i > 600
                begin
                    Timeout::timeout(30) do
                        result = %x[curl -s -S -u #{user}:#{password} -d status="#{msg}" #{url}]
    
                        if result.include? "error"
                            @lastfailure = Time.now
                            raise(Nagger::PluginConnectionError, "Update Failure")
                        else
                            @lastfailure = 0
                        end
                    end
                rescue Timeout::Error => e
                    @lastfailure = Time.now
                    raise(Nagger::PluginConnectionError, "Failed to connect to twitter within 10 seconds")
                end
            else
                raise(Nagger::PluginConnectionError, "Not delivering message, we've had failures in the last 10 mins")
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
