#!/usr/bin/ruby

require 'nagger'
require 'getoptlong'

opts = GetoptLong.new(
    [ '--config', '-c', GetoptLong::REQUIRED_ARGUMENT]
)

conffile = "/etc/nagger/nagger.cfg"

opts.each do |opt, arg|
    case opt
        when '--config'
            conffile = arg
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

daemonize do
    Nagger::Config.new(conffile)

    s = Nagger::Spool.new
    s.run
end

# vi:tabstop=4:expandtab:ai
