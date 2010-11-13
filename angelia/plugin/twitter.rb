require 'timeout'

# WARN: This plugin is made defunct by twitters crazy OAuth stuff.
#
# it's here for historical reference at this point.
module Angelia::Plugin
    class Twitter
        def initialize(config)
            Angelia::Util.debug("Creating new insance of Twitter plugin")

            @config = config
            @lastfailure = 0
        end

        def self.register
            Angelia::Util.register_plugin("twitter", "Twitter")
        end

        def send(recipient, subject, msg)
            Angelia::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")

            user = @config["username"]
            password = @config["password"]
            url = @config["url"]
            msg = msg[0..139]

            # if we had a failed delivery in the last 10 minutes do not try to send a new message
            # this is just to prevent us spamming twitter and getting in their bad books
            if Time.now.to_i - @lastfailure.to_i > 600
                begin
                    Timeout::timeout(30) do
                        result = %x[curl -s -S -u #{user}:#{password} -d status="#{msg}" #{url}]

                        if result.include? "error"
                            @lastfailure = Time.now
                            raise(Angelia::PluginConnectionError, "Update Failure")
                        else
                            @lastfailure = 0
                        end
                    end
                rescue Timeout::Error => e
                    @lastfailure = Time.now
                    raise(Angelia::PluginConnectionError, "Failed to connect to twitter within 10 seconds")
                end
            else
                raise(Angelia::PluginConnectionError, "Not delivering message, we've had failures in the last 10 mins")
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
