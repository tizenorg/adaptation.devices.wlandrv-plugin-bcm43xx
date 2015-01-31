#sbs-git:slp/pkgs/w/wlandrv-plugin wlandrv-plugin 0.0.1 6f86c1ed745b5f30c8e0c80545510458f922be61
%define debug_package %{nil}
Name:       wlandrv-plugin-tizen-bcm43xx
Summary:    Firmware & tools for broadcom
Version: 1.0.4
Release:    1
Group:      TO_BE/FILLED_IN
License:    TO BE FILLED IN
Source0:    %{name}-%{version}.tar.gz

%description
firmware & tools for broadcom

%prep
%setup -q

%build

%install
rm -rf %{buildroot}

mkdir -p %{buildroot}/lib/firmware
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/etc/rc.d/rc3.d

cp -af wlandrv-plugin-bcm43xx/* %{buildroot}/

ln -s ../init.d/wifi-module-check %{buildroot}/etc/rc.d/rc3.d/S01wifi-module-check

find wlandrv-plugin-bcm43xx/lib/firmware/*  -exec basename {} \; | sed 's/^/\/lib\/firmware\//g' >bcm.files
find wlandrv-plugin-bcm43xx/usr/bin/*  -exec basename {} \; | sed 's/^/\/usr\/bin\//g' >>bcm.files
find wlandrv-plugin-bcm43xx/etc/init.d/*  -exec basename {} \; | sed 's/^/\/etc\/init.d\//g' >>bcm.files

echo "/etc/rc.d/rc3.d/S01wifi-module-check" >>bcm.files

%files -f bcm.files
%defattr(-, root, root, -)
