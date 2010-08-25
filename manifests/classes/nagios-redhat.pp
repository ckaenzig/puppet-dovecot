class nagios::redhat inherits nagios::base {

  
  # logs
  $nagios_debug_level = "0"
  $nagios_debug_verbosity = "0"
  $nagios_log_file = "/var/log/nagios/nagios.log"
  $nagios_debug_file = "/var/log/nagios/nagios.debug"
  $nagios_log_archive_path ="/var/log/nagios/archives"

  # /var/run stuff
  $nagios_rw = "/var/run/nagios/rw/"
  $nagios_lock_file = "/var/run/nagios.pid"
  $nagios_state_retention_file = "/var/run/nagios/retention.dat"
  $nagios_temp_file = "/var/run/nagios/nagios.tmp"
  $nagios_command_file = "/var/run/nagios/rw/nagios.cmd"
  $nagios_status_file = "/var/run/nagios/status.dat"
  $nagios_precached_object_file = "/var/run/nagios/objects.precache"
  $nagios_object_cache_file = "/var/run/nagios/objects.cache"

  # /var/lib stuff
  $nagios_check_result_path = "/var/lib/nagios/spool/checkresults"

  # misc stuff
  $nagios_p1_file = "/usr/sbin/p1.pl"

  package {"nagios":
    ensure => present,
    alias  => "nagios3",
  }

  service {"nagios":
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    hasrestart  => true,
    require     => Package["nagios"],
    pattern     => "/usr/sbin/nagios -d /etc/nagios/nagios.cfg",
  }

  exec {"nagios-restart":
    command => "/usr/sbin/nagios -v ${nagios_main_config_file} && /etc/init.d/nagios restart",
    refreshonly => true,
    require => Package["nagios"],
  }

  exec {"nagios-reload":
    command     => "/usr/sbin/nagios -v ${nagios_main_config_file} && /etc/init.d/nagios reload",
    refreshonly => true,
    require     => Package["nagios"],
  }

  file {"/etc/default/nagios": ensure => absent }

  file {"/etc/nagios3":
    ensure  => absent,
  }

  file {["/var/run/nagios",
         "/var/lib/nagios",
         "/var/lib/nagios/spool",
         "/var/cache/nagios",
         "/var/lib/nagios/spool/checkresults",
        ]:
    ensure => directory,
    owner  => nagios,
    group  => nagios,
    mode   => 0744,
    require => Package["nagios"],
    before  => Service["nagios"],
  }

  file {"${nagios_root_dir}/resource.cfg":
    ensure  => present,
    mode    => 0644,
    owner   => root,
    group   => root,
  }

  nagios::resource { "USER1":
    value => $architecture ? {
      "i386"   => "/usr/lib/nagios/plugins",
      "x86_64" => "/usr/lib64/nagios/plugins",
    },
  }

  common::concatfilepart {"main":
    file    => $nagios_main_config_file,
    content => template("nagios/nagios.cfg.erb"),
    notify  => Exec["nagios-reload"],
    require => Package["nagios3"],
  }

  if defined( Class["apache"] ) {
    $group = "apache"
  } else {
    $group = "nagios"
  }

  file {$nagios_rw:
    ensure => directory,
    owner  => nagios,
    group  => $group,
    mode   => 0755,
    require => Package["nagios"],
  }

  if $lsbmajdistrelease == 5 and $operatingsystem == 'RedHat' {
    File["/var/run/nagios",
         "/var/lib/nagios",
         "/var/lib/nagios/spool",
         "/var/cache/nagios",
         "/var/lib/nagios/spool/checkresults",
         "$nagios_rw"] {
      seltype => "nagios_log_t",
    }
    exec {"chcon on $nagios_command_file":
      require => Exec["create node"],
      command => "chcon -t nagios_spool_t $nagios_command_file",
      unless  => "ls -Z $nagios_command_file | grep -q nagios_spool_t",
    }
    file {[$nagios_state_retention_file,
          $nagios_temp_file,
          $nagios_status_file,
          $nagios_precached_object_file,
          $nagios_object_cache_file]:
      ensure => present,
      seltype => "nagios_log_t",
      owner   => nagios,
      group   => nagios,
      require => File["/var/run/nagios"],
    }
    File[$nagios_state_retention_file] { mode => 0600 }
    File[$nagios_status_file] { mode => 0664 }
  }

  exec {"create node":
    require => File["$nagios_rw"],
    command => "mknod -m 0664 $nagios_command_file p && chown nagios:${group} $nagios_command_file",
    unless  => "test -p $nagios_command_file"
  }
}
