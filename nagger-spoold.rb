#!/usr/bin/ruby

require 'nagger'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT ],
    [ '--foreground', '-f', GetoptLong::NO_ARGUMENT ]
)

want_daemon = true
conffile = "/etc/nagger/nagger.cfg"

opts.each do |opt, arg|
    case opt
        when '--config'
            conffile = arg
        when '--foreground'
            want_daemon = false
    end
end


# Goes into the background, chdir's to /tmp, and redirect all input/output to null
# Beginning Ruby p. 489-490
def daemonize
    fork do
        Process.setsid
        exit if fork
        #Dir.chdir('/tmp')
        STDIN.reopen('/dev/null')
        STDOUT.reopen('/dev/null', 'a')
        STDERR.reopen('/dev/null', 'a')

        trap("TERM") { 
            exit
        }

        yield
    end
end

# Do this outside of daemonize, in case there are errors
Nagger::Config.new(conffile)
s = Nagger::Spool.new

if want_daemon
    daemonize do
        s.run
    end
else
     s.run
end

# vi:tabstop=4:expandtab:ai
