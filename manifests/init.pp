# Class: jenkins
#
# For installing and managing Jenkins (continuous integration server)
# Requires:
#   - apt module from https://github.com/camptocamp/puppet-apt
#   - nginx module, or at least nginx.conf must include the line
#       include /etc/nginx/conf.d/*.conf;
#     at the bottom of the http{} context.
#   - java
#
class jenkins($server = "nginx") {

  apt::source { "jenkins":
    location => "http://pkg.jenkins-ci.org/debian",
    release => "binary/",
    repos => "",
    key => "D50582E6",
    key_server => "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key",
    include_src => false,
  }

  package { "jenkins":
    ensure  => installed,
    require => [ Apt::Source["jenkins"], Class["java"] ],
  }

  service { "jenkins":
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