require 'rubygems'
require 'xmpp4r'
require 'timeout'

module Nagger::Plugin
    class Xmpp
        include Jabber

        def initialize(config)
            Nagger::Util.debug("Creating new insance of XMPP plugin")

            @config = config

            connect
        end

        def self.register
            Nagger::Util.register_plugin("xmpp", "Xmpp")
        end

        def send(recipient, subject, msg)
            Nagger::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")
            m = Jabber::Message::new(recipient, msg).set_type(:normal).set_id('1').set_subject(subject)

            if @cl.status == 1
                reconnect
            end

            if @cl.status == 2
                @cl.send(m)
            else
                raise(Nagger::PluginConnectionError, "Not connected to transport")
            end
        end

        private
        def reconnect
            # TODO: Keep some kind of count about reconnects and only connect once in a while
            Nagger::Util.debug("Reconnecting to XMPP server")
            connect
        end

        def connect
            begin
                Timeout::timeout(10) do
                    username = @config["username"]
                    domain = @config["domain"]
                    resource = @config["resource"]
                    password = @config["password"]
                    server = @config["server"]

                    jid = JID::new(username + "@" + domain + "/" + resource)

                    @cl = Client::new(jid)
                    @cl.connect(server)
                    @cl.auth(password)
                    @cl.send(Presence.new)

                    sleep 1
                end
            rescue Timeout::Error => e
                Nagger::Util.warn("Could not connect to jabber server, will try later")
            end

        end
    end
end

# vi:tabstop=4:expandtab:ai
