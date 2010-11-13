%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define release %{rpm_release}%{?dist}

Summary: Multi protocol nagios notifier
Name: angelia
Version: %{version}
Release: %{release}
Group: System Tools
License: Apache v2
URL: http://www.devco.net/
Source0: %{name}-%{version}.tgz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: ruby
BuildArch: noarch
Packager: R.I.Pienaar <rip@devco.net>

%description
System to send nagios alerts to multiple destinations such as Twitter and XMPP.

Features:
 - Templates for each type of protocol and alert
 - Simple integration into Nagios
 - Supports Twitter and XMPP


%prep
%setup -q

%build

%install
rm -rf %{buildroot}
%{__install} -d -m0755  %{buildroot}/%{ruby_sitelib}/angelia
%{__install} -d -m0755  %{buildroot}/etc/angelia/templates
%{__install} -d -m0755  %{buildroot}/usr/sbin
%{__install} -d -m0755  %{buildroot}/var/spool/angelia
%{__install} -d -m0755  %{buildroot}/var/log/angelia
%{__install} -d -m0755  %{buildroot}/etc/init.d
%{__install} -m0755 angelia-nagios-send.rb %{buildroot}/usr/sbin/angelia-nagios-send
%{__install} -m0755 angelia-send.rb %{buildroot}/usr/sbin/angelia-send
%{__install} -m0755 angelia-spoold.rb %{buildroot}/usr/sbin/angelia-spoold
%{__install} -m0755 angelia.init %{buildroot}/etc/init.d/angelia
cp -R angelia.rb %{buildroot}/%{ruby_sitelib}/
cp -R angelia/* %{buildroot}/%{ruby_sitelib}/angelia/
cp -R templates/* %{buildroot}/etc/angelia/templates
cp angelia.cfg %{buildroot}/etc/angelia

%clean
rm -rf %{buildroot}

%post
/sbin/chkconfig --add angelia

%preun
if [ "$1" = 0 ]; then
   /sbin/service angelia stop >/dev/null 2>&1 || :;
   /sbin/chkconfig --del angelia || :;
fi
:;

%postun
if [ "$1" -ge 1 ]; then
   /sbin/service angelia condrestart >/dev/null 2>&1 || :;
fi;
:;

%files
%{ruby_sitelib}/angelia.rb
%{ruby_sitelib}/angelia
%config(noreplace) /etc/angelia/angelia.cfg
%config /etc/angelia/templates
%config /etc/init.d/angelia
/var/spool/angelia
/var/log/angelia
/usr/sbin/angelia-nagios-send
/usr/sbin/angelia-send
/usr/sbin/angelia-spoold


%changelog
* Thu Jul 23 2009 R.I.Pienaar <rip@devco.net> - 0.1
- First release
