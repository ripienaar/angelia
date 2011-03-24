require'rubygems'
require 'notifo'

module Angelia::Plugin
    # Plugin to deliver push notifications to iPhones and iPads using http://notifo.com
    #
    # plugin = Notifo
    # plugin.notifo.service = xxxx 
    # plugin.notifo.apikey = yyyyyyyy
    # plugin.Notifo.url = http://monitoring.domain.com
    class Notifo
        def initialize(config)
            Angelia::Util.debug("Creating new insance of Notifo plugin")

            @config = config
            @lastfailure = 0
        end

        def self.register
            Angelia::Util.register_plugin("notifo", "Notifo")
        end

        def send(recipient, subject, msg)
            Angelia::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")

            service = @config["service"]
            apikey = @config["apikey"]
            url = @config["url"]

            begin
                notifo = ::Notifo.new(service, apikey)
                res = notifo.post(recipient, msg, subject, url)

                if res.code == 200
                    return 0
                else
                    raise(Angelia::PluginConnectionError, "Could not send message, api code: #{res.code}")
                end
            rescue Exception => e
                raise(Angelia::PluginConnectionError, "Unhandled issue sending alert: #{e}")
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
