module Nagger
    # Class that manages the spool, checks for new messages and delivers them.
    class Spool
        def initialize
            @config = Nagger::Util.config
        end

        # The main worker part of the class, this opens the spool dir, looks for new
        # messages and route them to the plugins via Nagger::Util.route
        #
        # Spool messages are YAML dumps of Nagger::Message objects.
        #
        # Expected problems should all result in a Nagger::CorruptMessage exception but
        # other exceptions should still be handled too.
        def run
            Nagger::Util.info("Nagger::Spool starting on #{@config.spooldir}")
            if File.exists?(@config.spooldir)
                while true
                    Dir.open(@config.spooldir) do |dir|
                        Nagger::Util.debug("Checking for files in spooldir")

                        dir.each do |file|
                            next if file =~ /^\.\.?$/
                            next unless file =~ /\.msg$/

                            spoolfile = "#{@config.spooldir}/#{file}"

                            begin
                                msg = YAML.load_file(spoolfile)
                                

                                Nagger::Util.route(msg)

                                Nagger::Util.info("Mmessage in #{spoolfile} to #{msg.recipient.protocol}://#{msg.recipient.user} has been delivered")

                                File.unlink("#{spoolfile}")

                            rescue Nagger::CorruptMessage => e
                                Nagger::Util.warn("Found a corrupt message in #{file}: #{e}, unlinking #{spoolfile}")
                                File.unlink("#{spoolfile}")

                            rescue Exception => e
                                Nagger::Util.warn("Could not send message in file #{file}: #{e}, will retry")
                            end
                        end
                    end

                    sleep 5
                end
            else
                raise("Spool directory (#{@config.spooldir}) does not exist")
            end
        end

        # Simple helper to create a Nagger::Message object and dump it
        # into the spool in a relatively safe way.
        def self.createmsg(message)
            name = "#{Time.now.to_f}-#{rand(10000000)}-#{$$}"
            config = Nagger::Util.config

            message.subject = "Nagger Alert" unless message.subject

            File.open("#{config.spooldir}/#{name}.part", 'w') do |f| 
                YAML.dump(message, f)
            end

            File.rename("#{config.spooldir}/#{name}.part", "#{config.spooldir}/#{name}.msg")

            Nagger::Util.debug("New message created in the spool @ #{config.spooldir}/#{name}.msg")
        end
    end
end
# vi:tabstop=4:expandtab:ai
