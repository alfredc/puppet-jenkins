# Class: jenkins
#
# For installing and managing Jenkins (continuous integration server)
# Requires nginx module, or at least nginx.conf must include the line
#   include /etc/nginx/conf.d/*.conf;
# at the bottom of the http{} context.
#
class jenkins($server = "nginx") {

  include apt

  apt::key {"D50582E6":
    source  => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
  }

  apt::sources_list {"jenkins":
    ensure  => present,
    content => "deb http://pkg.jenkins-ci.org/debian binary/",
    require => Apt::Key["D50582E6"],
  }

  package { ["openjdk-6-jre", "openjdk-6-jdk"]:
    ensure => installed,
  }

  package {"jenkins":
    ensure  => installed,
    require => [ Apt::Sources_list["jenkins"], Package["openjdk-6-jre"], Package["openjdk-6-jdk"] ],
  }

  service {"jenkins":
    enable  => true,
    ensure  => running,
    hasrestart => true,
    require => Package["jenkins"],
  }
  
  if $server == "nginx" {
    #package { "nginx":
    #  ensure => installed,
    #}

    #service { "nginx":
    #  ensure => running,
    #  enable => true,
    #  require => Package["nginx"],
    #}

    file { "/etc/nginx/conf.d/nginx-jenkins.conf":
      owner => root,
      group => root,
      mode => 644,
      ensure => present,
      content => template("jenkins/nginx-jenkins.conf.erb"),
      require => Package["nginx"],
      notify => Service["nginx"],
    }
  }

}