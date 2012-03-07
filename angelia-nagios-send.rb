#!/usr/bin/ruby

require 'angelia'
require 'getoptlong'

conffile = nil
recipient = nil
subject = ""
message = ""
mode = nil
backend = "nagios"

opts = GetoptLong.new(
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT],
    [ '--recipient', '-r', GetoptLong::REQUIRED_ARGUMENT],
    [ '--subject', '-s', GetoptLong::REQUIRED_ARGUMENT],
    [ '--icinga',  GetoptLong::NO_ARGUMENT],
    [ '--host-notify', GetoptLong::NO_ARGUMENT],
    [ '--service-notify', GetoptLong::NO_ARGUMENT],
    [ '--message', '-m', GetoptLong::REQUIRED_ARGUMENT]
)

opts.each do |opt, arg|
    case opt
        when '--config'
            conffile = arg
        when '--recipient'
            recipient = arg
        when '--subject'
            subject = arg
        when '--icinga'
            backend = 'icinga' 
        when '--host-notify'
            mode = 'host'
        when '--service-notify'
            mode = 'service'
        when '--message'
            message = arg.gsub "\\n", "\n"
    end
end

unless File.exists? conffile
    raise "Can't find config file #{conffile}"
end

unless mode
    raise "Must supply either --host-notify or --service-notify"
end

begin
    Angelia::Config.new(conffile, false)

    Angelia::Spool.createmsg Angelia::Message.new(recipient, message, subject, "#{backend}-#{mode}")

rescue Angelia::CorruptMessage => e
    Angelia::Util.fatal("Could not create message: #{e}")

rescue Exception => e
    $stderr.puts("Fatal error, message not sent: #{e}")
    raise
end

# vi:tabstop=4:expandtab:ai
