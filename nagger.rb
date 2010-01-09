require 'yaml'

# This is a tool to facilite the development of nagios notification
# methods using many different protocols and delivery systems while
# using a single simple script that can deliver all messages.
#
# Messages have recipients in the form:
#
#    protocol://recipient
#
# and each protocol gets handled by a different plugin.
#
# At present there are just two plugins that serve as a introduction to the 
# plugin system, see [Nagger::Plugin::Twitter] and [Nagger::Plugin::Xmpp].
#
# When called from inside nagios a script - nagger-nagios-send - should be used
# it will assist in building up the message bodies by means of templates and the
# state provided by nagios, each protocol can have its own templates for host and
# service notifies, these are in files:
#
#    templates/protocol-host.erb
#    templates/protocol-service.erb
#
# And you can use any of the NAGIOS_* variables that Nagios sets in the environment.
#
# Normal messages can be send using nagger-send, in this case you need to provide
# your own message body.
#
# Sample calls to put messages on the spool are:
#
#    nagger-nagios-send -c /etc/nagger/nagger.cfg --service-notify -r xmpp://you@jabber.com
#    nagger-send -c /etc/nagger/nagger.cfg -r xmpp://you@jabber.com -m 'my message'
#
# Included in the tarball are init scripts, daemon to run and pol the spool etc.
#
# Contact rip <at> devco.net with any questions.
module Nagger
    autoload :Util, "nagger/util.rb"
    autoload :Config, "nagger/config.rb"
    autoload :Spool, "nagger/spool.rb"
    autoload :Message, "nagger/message.rb"
    autoload :Recipient, "nagger/recipient.rb"
end

# vi:tabstop=4:expandtab:ai
