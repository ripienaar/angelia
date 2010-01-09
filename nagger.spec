%define ruby_sitelib %(ruby -rrbconfig -e "puts Config::CONFIG['sitelibdir']")
%define release %{rpm_release}%{?dist}

Summary: Multi protocol nagios notifier
Name: nagger
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
%{__install} -d -m0755  %{buildroot}/%{ruby_sitelib}/nagger
%{__install} -d -m0755  %{buildroot}/etc/nagger/templates
%{__install} -d -m0755  %{buildroot}/usr/sbin
%{__install} -d -m0755  %{buildroot}/var/spool/nagger
%{__install} -d -m0755  %{buildroot}/var/log/nagger
%{__install} -d -m0755  %{buildroot}/etc/init.d
%{__install} -m0755 nagger-nagios-send.rb %{buildroot}/usr/sbin/nagger-nagios-send
%{__install} -m0755 nagger-send.rb %{buildroot}/usr/sbin/nagger-send
%{__install} -m0755 nagger-spoold.rb %{buildroot}/usr/sbin/nagger-spoold
%{__install} -m0755 nagger.init %{buildroot}/etc/init.d/nagger
cp -R nagger.rb %{buildroot}/%{ruby_sitelib}/
cp -R nagger/* %{buildroot}/%{ruby_sitelib}/nagger/
cp -R templates/* %{buildroot}/etc/nagger/templates
cp nagger.cfg %{buildroot}/etc/nagger

%clean
rm -rf %{buildroot}

%post
/sbin/chkconfig --add nagger

%preun
if [ "$1" = 0 ]; then
   /sbin/service nagger stop >/dev/null 2>&1 || :;
   /sbin/chkconfig --del nagger || :;
fi
:;

%postun
if [ "$1" -ge 1 ]; then
   /sbin/service nagger condrestart >/dev/null 2>&1 || :;
fi;
:;

%files
%{ruby_sitelib}/nagger.rb
%{ruby_sitelib}/nagger
%config(noreplace) /etc/nagger/nagger.cfg
%config /etc/nagger/templates
%config /etc/init.d/nagger
/var/spool/nagger
/var/log/nagger
/usr/sbin/nagger-nagios-send
/usr/sbin/nagger-send
/usr/sbin/nagger-spoold


%changelog
* Thu Jul 23 2009 R.I.Pienaar <rip@devco.net> - 0.1
- First release
