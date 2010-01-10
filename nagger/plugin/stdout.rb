module Nagger::Plugin

    # A simple stdout plugin for quickly testing templates
    class Stdout
        def initialize(config)
            Nagger::Util.debug("Creating new instance of Stdout plugin")

            @config = config
        end

        def self.register
            Nagger::Util.register_plugin("stdout", "Stdout")
        end

        def send(recipient, subject, msg)
            Nagger::Util.debug("#{self.class} Sending message to '#{recipient}' with subject '#{subject}' and body '#{msg}'")
            puts "To: #{recipient}"
            puts "Subject: #{subject}"
            puts
            puts msg
        end
    end
end

# vi:tabstop=4:expandtab:ai
