class app-c2c-sig-blonay-cartoriviera {

  group {"admin":
    ensure  => present,
    require => User["admin"],
  }
  
  apache::vhost {"map.cartoriviera.ch":
    ensure  => present,
    group   => admin,
    mode    => 2775,
  }

  apache::vhost {"preprod.cartoriviera.ch":
    ensure  => present,
    group   => admin,
    mode    => 2775,
  }

  apache::vhost {"www.cartoriviera.ch":
    ensure  => present,
    group   => admin,
    mode    => 2775,
  }

  apache::vhost {"blonay-cartoriviera":
    ensure => absent,
  }

  apache::auth::htpasswd {"cartoriviera in /var/www/preprod.cartoriviera.ch/private/htpasswd":
    ensure => present,
    vhost => "preprod.cartoriviera.ch",
    username => "cartoriviera",
    clearPassword => "cartoriviera",
  }

  apache::auth::basic::file::user {"user1-on-webdav2":
    vhost    => "preprod.cartoriviera.ch",
    location => "/",
    users    => "cartoriviera",
    ensure   => absent,
  }

  tomcat::instance {"print":
    ensure => present,
    group  => admin,
  } 

  user {"admin":
    ensure     => present,
    managehome => true,
    home       => "/home/admin",
    shell      => "/bin/bash",
    groups     => ["www-data", "sigdev"],
  }

  c2c::ssh_authorized_key{
    "alex on admin"     : sadb_user => "alex",      user => "admin", require => User["admin"];
    "ebelo on admin"    : sadb_user => "ebelo",     user => "admin", require => User["admin"];
    "bquartier on admin": sadb_user => "bquartier", user => "admin", require => User["admin"];
  }

  c2c::sshuser {"ygillieron": 
    ensure  => present, 
    groups  => "admin", 
    uid     => 2000, 
    comment => "y.gillieron@b-t-i.ch", 
    email   => "y.gillieron@b-t-i.ch",
    type    => "rsa", 
    key     => "AAAAB3NzaC1yc2EAAAABJQAAAIEAkc3duX7LBHnQndfFLgIVd8OCVkyNxBwz81MAO1TXkjVLi5TnkBngHe7w1oLOmygylVNd6Grag/iY9NX/6YilYTqRg4Q/RaYJBfG37o3ur4wnGYaHaAjyPTyT96RVvQ5DrVSaPlPWRCRgSxL6CUfrUx23mjP/JRCSAs55PxMwy+8=";
  }

  c2c::sshuser {"tcachin": 
    ensure  => present, 
    groups  => "admin", 
    uid     => 2005, 
    comment => "tcachin@blonay.ch", 
    email   => "tcachin@blonay.ch",
    type    => "rsa", 
    key     => "AAAAB3NzaC1yc2EAAAABJQAAAIEAwtEQHB2J6f9y4RERcIZ7QcqBtUWsSgeGHAAOFfrU8t4FV/sNJnt5CAwpWXbDreVQfA8gjmrkeCkdEe5G2IVuqyN6mxTs4IeeWwIATvJA1NBOGXb79FONkiOh1B7hDfrkLdAACn1tykFiwPk+psFnFrdFUWA9fzEmJIJMXUYLKl0=";
  }

  c2c::sshuser {"buchsl": 
    ensure  => present, 
    groups  => "admin", 
    uid     => 2006, 
    comment => "laurent.buchs@sige.ch", 
    email   => "laurent.buchs@sige.ch",
    type    => "rsa", 
    key     => "AAAAB3NzaC1yc2EAAAABJQAAAIEAzUykFAtryuOPkAwMc0aItNGQvfurykXngWqIhQLlDMwrV5w1a5EvfMRUiGqZOYMv/fugieXYDG391JsE9jtUI4S8JqqYI9XoL9b9z77Ml2lNYXLtpfpqsDmaYZj/npM5sR8Q0tt9X+ak8er/b2SZTuD+r4rMlT9L1b3WhqsVyyU=";
  }

  c2c::sshuser {"vrizzi":
    ensure  => present, 
    groups  => "admin", 
    uid     => 2007, 
    comment => "v.rizzi@b-t-i.ch", 
    email   => "v.rizzi@b-t-i.ch",
    type    => "rsa", 
    key     => "AAAAB3NzaC1yc2EAAAABJQAAAIEA1LquxRLS/K6zWZ4rFZaiMwHVnze4i4AsCv7FmApvwLPBMDVGkaiDpEq/alargiWEdS7ir2wMnbDq1GsKueOGtdeRhCugwBvwhuhZLY7I+daq6HceZWlFgrxxCe6mJ2lsyMVTJ85lk8a8utUe4MbxP8gRFbLI4N5LsDvQsoRtQTE=";
  }

  c2c::sshuser {"dgnerre":
    ensure  => present, 
    groups  => "admin", 
    uid     => 2008, 
    comment => "Daniel.Gnerre@vevey.ch", 
    email   => "Daniel.Gnerre@vevey.ch",
    type    => "rsa", 
    key     => "AAAAB3NzaC1yc2EAAAABJQAAAIBpJD6b/3vO+1zOJITkCfvAKf6KEwwClYA5MpnVydY9HMDj8IFUMN0V8iWGq9o136vnMy2pZ0m4PBybwec2/EklDcADpkbSoz5xXviyjvQHF6f0s1cR/GAt5944SZxhq+PPVLrfkh85bH/hPkxLVTb8JyjGvVAMKvtpnjSlEUxdOQ==";
  }

}
