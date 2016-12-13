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
#   family.
#
# [*awscli*]
#   Set in ec2tagfacts::params, this is the pip package name of awscli.
#
# [*rubyjsonpkg*]
#   Set in ec2tagfacts::params, this is the ruby-json package name.
#
# [*enable_epel*]
#   True/False - sets up EPEL on RHEL systems automatically.
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
        $pippkg       = false # centos7 has pip installed by default even on min
        $rubyjsonpkg  = 'rubygem-json'
      } else {
        $pippkg       = 'python-pip'
        $rubyjsonpkg  = 'ruby-json'
      }
    }
    'Fedora': {
      $pippkg       = 'python-pip'
      $awscli       = 'awscli'
      $enable_epel  = true
      if ($::operatingsystemmajrelease + 0) >= (22 + 0) {
        $rubyjsonpkg  = 'rubygem-json'
      } else {
        $rubyjsonpkg  = 'ruby-json'
      }
    }
    'Scientific', 'SLC', 'Ascendos', 'CloudLinux', 'PSBM', 'OVS': {
      $pippkg       = 'python-pip'
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = true
    }
    'Gentoo': {
      $pippkg       = 'dev-python/pip'
      $rubyjsonpkg  = 'dev-ruby/json'
      $awscli       = 'aws-cli'
      $enable_epel  = false
    }
    'Amazon': {
      $pippkg       = false
      $rubyjsonpkg  = 'rubygem18-json'
      $awscli       = 'aws-cli'
      $enable_epel  = false
    }
    'ubuntu', 'debian': {
      $pippkg       = 'python-pip'
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = false
    }
    'SLES', 'SLED', 'OpenSuSE', 'SuSE': {
      $pippkg       = 'python-pip'
      $rubyjsonpkg  = 'ruby-json'
      $awscli       = 'awscli'
      $enable_epel  = false
    }
    default: {
      fail("Unsupported platform: ${::osfamily}/${::operatingsystem}")
    }
  }

}
