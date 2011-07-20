# Class: jenkins
#
# For installing and managing Jenkins (continuous integration server)
# Requires nginx module, or at least nginx.conf must include the line
#   include /etc/nginx/conf.d/*.conf;
# at the bottom of the http{} context.
#
class jenkins($server = "nginx") {

  package { ["openjdk-6-jre", "openjdk-6-jdk"]:
    ensure => installed,
  }

  exec { "jenkins-key":
    command => "/usr/bin/wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -",
  }

  exec { "jenkins-source":
    command => "/bin/echo \"deb http://pkg.jenkins-ci.org/debian binary/\" > /etc/apt/sources.list.d/jenkins.list",
    require => Exec["jenkins-key"],
  }

  exec { "apt-update":
    command => "/usr/bin/apt-get update",
    require => Exec["jenkins-source"],
  }

  package { "jenkins":
    ensure => installed,
    require => [ Package["openjdk-6-jre"], Package["openjdk-6-jdk"], Exec["apt-update"] ],
  }

  service { "jenkins":
    ensure => running,
    enable => true,
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