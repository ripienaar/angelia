require 'rubygems'
require 'clickatell'

module Nagger::Plugin
    # Plugin that sends SMS messages via Clickatell, needs the Clickatell gem from 
    # http://clickatell.rubyforge.org/
    #
    # plugin = Clickatell
    # plugin.Clickatell.user = xxx
    # plugin.Clickatell.password = yyyyy
    # plugin.Clickatell.apikey = 123
    # plugin.Clickatell.senderid = 123
    #
    # You can then send emails to subscribed people using clickatell://0044xxxxxxxxxxx
    class Clickatell
        def initialize(config)
            Nagger::Util.debug("Creating new insance of Clickatell plugin")

            @config = config
            @lastfailure = 0
        end

        def self.register
            Nagger::Util.register_plugin("clickatell", "Clickatell")
        end

        def send(recipient, subject, msg)
            Nagger::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")

            apikey = @config["apikey"]
            user = @config["user"]
            password = @config["password"]
            senderid = @config["senderid"]

            begin
                ct = ::Clickatell::API.authenticate(apikey, user, password)
                res = ct.send_message(recipient, msg, {:from => senderid})
            rescue Clickatell::API::Error => e
                raise "Unable to send message: #{e}"
            rescue Exception => e
                raise(Nagger::PluginConnectionError, "Unhandled issue sending alert: #{e}")
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
