# == Class: ec2tagfacts::params
#
# automatic parameter and settings for the ec2tagfacts class
#
# === Variables
#
# [*aws_cli_ini_settings*]
#   Path to awscli credentials file. Default '/root/.aws/credentials'
#
# [*pippkg*]
#   Set in ec2tagfacts::params, this is the Python pip package name by OS
#   family. Set to false when installing with a non-pip method like yum.
#
# [*awscli*]
#   Set in ec2tagfacts::params, this is the package name of awscli.
#
# [*rubyjsonpkg*]
#   Set in ec2tagfacts::params, this is the ruby-json package name.
#
# [*enable_epel*]
#   True/False - sets up EPEL on RHEL systems automatically.
#
# [*awscli_pkg*]
#   awscli package provider. Mostly pip but some distros provide packages.
#
# === Authors
#
# Bryan Andrews <bryanandrews@gmail.com>
#
# === Copyright
#
# Copyright 2015 Bryan Andrews, unless otherwise noted.
#
#
# NOTE: The unnecessary math below is to ensure the string is an int for comparison
#
class ec2tagfacts::params {

  $aws_cli_ini_settings = '/root/.aws/credentials'

  case $::operatingsystem {
    'CentOS', 'RedHat' , 'OEL', 'OracleLinux': {
      $awscli       = 'awscli'
      $enable_epel  = true
      if ($::operatingsystemmajrelease + 0) >= (7 + 0) {
        $pippkg       = false # centos7 has awscli in epel as an rpm
        $rubyjsonpkg  = 'rubygem-json'
        $awscli_pkg   = 'yum' # package provider for centos7
      } else {
        $pippkg       = 'python-pip'
        $rubyjsonpkg  = 'ruby-json'
        $awscli_pkg   = 'pip' # package provider for centos6
      }
    }
    'Fedora': {
      $awscli       = 'awscli'
      $enable_epel  = true
      if ($::operatingsystemmajrelease + 0) >= (22 + 0) {
        $pippkg       = false
        $rubyjsonpkg  = 'rubygem-json'
        $awscli_pkg   = 'yum'
      } else {
        $pippkg       = 'python-pip'
        $rubyjsonpkg  = 'ruby-json'
        $awscli_pkg   = 'pip'
      }
    }
    'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OVS': {
      $pippkg       = 'python-pip'
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = true
      $awscli_pkg   = 'pip'
    }
    'Gentoo': {
      $pippkg       = false
      $rubyjsonpkg  = 'dev-ruby/json'
      $awscli       = 'aws-cli'
      $enable_epel  = false
      $awscli_pkg   = 'portage'
    }
    'Amazon': {
      $pippkg       = false
      $rubyjsonpkg  = 'rubygem18-json'
      $awscli       = 'aws-cli'
      $enable_epel  = false
      $awscli_pkg   = 'yum'
    }
    'ubuntu', 'debian': {
      $pippkg       = false
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = false
      $awscli_pkg   = 'apt'
    }
    'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
      $pippkg       = 'python-pip'
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = false
      $awscli_pkg   = 'pip'
    }
    default: {
      fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
    }
  }

}
