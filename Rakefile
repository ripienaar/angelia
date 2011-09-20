# Rakefile to build a project using HUDSON

require 'rake/rdoctask'
require 'rake/clean'

PROJ_NAME = "angelia"
PROJ_FILES = ["build/doc", "angelia-nagios-send.rb", "angelia-send.rb", "#{PROJ_NAME}.rb", "#{PROJ_NAME}", "#{PROJ_NAME}.spec", "templates", "#{PROJ_NAME}.cfg", "#{PROJ_NAME}.init", "angelia-spoold.rb", "COPYING"]
PROJ_DOC_TITLE = "Angelia - Notification System"
PROJ_VERSION = "1.0.0"
PROJ_RELEASE = "1"
PROJ_RPM_NAMES = [PROJ_NAME]

ENV["RPM_VERSION"] ? CURRENT_VERSION = ENV["RPM_VERSION"] : CURRENT_VERSION = PROJ_VERSION
ENV["BUILD_NUMBER"] ? CURRENT_RELEASE = ENV["BUILD_NUMBER"] : CURRENT_RELEASE = PROJ_RELEASE

CLEAN.include("build")

def announce(msg='')
  STDERR.puts "================"
  STDERR.puts msg
  STDERR.puts "================"
end

def init
    FileUtils.mkdir("build") unless File.exist?("build")
end

desc "Build documentation, tar balls and rpms"
task :default => [:clean, :doc, :archive, :rpm] do
end

# taks for building docs
rd = Rake::RDocTask.new(:doc) { |rdoc|
    announce "Building documentation for #{CURRENT_VERSION}"

    rdoc.rdoc_dir = 'build/doc'
    rdoc.template = 'html'
    rdoc.title    = "#{PROJ_DOC_TITLE} version #{CURRENT_VERSION}"
    rdoc.options << '--line-numbers' << '--inline-source' << '--main=Angelia'
}

desc "Create a tarball for this release"
task :archive => [:clean, :doc] do
    announce "Creating #{PROJ_NAME}-#{CURRENT_VERSION}.tgz"

    FileUtils.mkdir_p("build/#{PROJ_NAME}-#{CURRENT_VERSION}")
    system("cp -R #{PROJ_FILES.join(' ')} build/#{PROJ_NAME}-#{CURRENT_VERSION}")
    system("cd build && /bin/tar --exclude .svn -cvzf #{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{PROJ_NAME}-#{CURRENT_VERSION}")
end

desc "Creates a RPM"
task :rpm => [:archive] do
    announce("Building RPM for #{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}")

    sourcedir = `/bin/rpm --eval '%_sourcedir'`.chomp
    specsdir = `/bin/rpm --eval '%_specdir'`.chomp
    srpmsdir = `/bin/rpm --eval '%_srcrpmdir'`.chomp
    rpmdir = `/bin/rpm --eval '%_rpmdir'`.chomp
    lsbdistrel = `/usr/bin/lsb_release -r -s|/bin/cut -d . -f1`.chomp
    lsbdistro = `/usr/bin/lsb_release -i -s`.chomp

    case lsbdistro
        when 'CentOS'
            rpmdist = "el#{lsbdistrel}"
        when 'AmazonAMI'
            rpmdist = 'amzn1'
        else
            rpmdist = ''
    end

    sh %{cp build/#{PROJ_NAME}-#{CURRENT_VERSION}.tgz #{sourcedir}}
    sh %{cp #{PROJ_NAME}.spec #{specsdir}}

    sh %{cd #{specsdir} && rpmbuild -D 'version #{CURRENT_VERSION}' -D 'rpm_release #{CURRENT_RELEASE}' -D 'dist .#{rpmdist}' -ba #{PROJ_NAME}.spec}

    sh %{cp #{srpmsdir}/#{PROJ_NAME}-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.src.rpm build/}

    sh %{cp #{rpmdir}/*/#{PROJ_NAME}*-#{CURRENT_VERSION}-#{CURRENT_RELEASE}.#{rpmdist}.*.rpm build/}
end

# vi:tabstop=4:expandtab:ai
