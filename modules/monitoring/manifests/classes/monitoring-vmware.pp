class monitoring::vmware {

  include monitoring::params

  $vmware = $lsbdistcodename ? {
    /^(Nahant|lenny)/ => "vmware-guestd",
    Tikanga           => "vmtoolsd",
  }

  monitoring::check { "Process: $vmware":
    codename => "check_vmware_process",
    command  => "check_procs",
    options  => "-w 1:1 -c 1:1 -C ${vmware}",
    interval => "60",
    retry    => "30",
    type     => "passive",
    server   => $nagios_nsca_server,
    package  => $operatingsystem ?{
      /RedHat|CentOS/ => "nagios-plugins-procs",
      default => false
    }
  }

  file { "${monitoring::params::customplugins}/check_vmware_kmods.sh":
    mode    => 0755,
    owner   => "root",
    group   => "root",
    before  => Monitoring::Check["Vmware: kernel modules"],
    content => '#!/bin/sh

# file managed by puppet

mods="vmsync vmmemctl vmhgfs"

for m in $mods; do
  if ! $(lsmod | egrep -q "^$m +"); then
    echo "Module \"$m\" is not loaded in kernel."
    exit 2
  fi
done

echo "Modules \"$mods\" loaded in kernel."
exit 0
',
  }

  monitoring::check { "Vmware: kernel modules":
    codename => "check_vmware_kmods",
    command  => "check_vmware_kmods.sh",
    base     => "${monitoring::params::customplugins}",
    interval => "60",
    retry    => "30",
    type     => "passive",
    server   => $nagios_nsca_server,
  }
}