# == Class: ec2tagfacts
#
# EC2 tags are turned into puppet facts. AWS cli automatically installed.
#
# === Parameters
#
# [*aws_access_key_id*]
#   This is an aws_access_key_id with policy rights to read tags.
#
# [*aws_secret_access_key*]
#   This is the secret_access_key to the above key id.
#
# [*aws_cli_ini_settings*]
#   Full path to the aws cli ini file to store credentials. Default is provided.
#
# [*enable_epel*]
#   True to enable EPEL automatically, false not to. Automatically set in 
#   ec2tagfacts::params based on OS family.
#
# === Variables
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
# === Examples
#
#  class { 'ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#  }
#
# === Authors
#
# Bryan Andrews <bryanandrews@gmail.com>
#
# === Copyright
#
# Copyright 2015 Bryan Andrews, unless otherwise noted.
#
class ec2tagfacts (

  $aws_access_key_id      = undef,  # if undef we assume they are setup correctly already
  $aws_secret_access_key  = undef,
  $aws_cli_ini_settings   = $ec2tagfacts::params::aws_cli_ini_settings,
  $enable_epel            = $ec2tagfacts::params::enable_epel,

) inherits ec2tagfacts::params {

  $pippkg                 = $ec2tagfacts::params::pippkg
  $awscli                 = $ec2tagfacts::params::awscli
  $rubyjsonpkg            = $ec2tagfacts::params::rubyjsonpkg

  if (!is_string($aws_access_key_id)) {
    fail('ERROR: ec2tagfacts::aws_access_key_id must be a string')
  }

  if (!is_string($aws_secret_access_key)) {
    fail('ERROR: ec2tagfacts::aws_secret_access_key must be a string')
  }

  if $enable_epel {
    include epel
    Class['epel'] -> Package[$pippkg]
  }

  if $pippkg != undef {

    package { $pippkg:
      ensure => 'installed',
    }

    package { $awscli:
      ensure   => 'installed',
      provider => 'pip',
      require  => Package[$pippkg],
    }

  } else {

    package { $awscli:
      ensure   => 'installed',
    }

  }

  if $rubyjsonpkg != undef {
    package { $rubyjsonpkg:
      ensure => 'installed',
    }
  }

  if ($aws_secret_access_key != undef) and ($aws_access_key_id != undef) { 

    $directory = dirname($aws_cli_ini_settings)
    file { $directory:
      ensure  => directory,
      require => Package[$awscli],
      recurse => true,
    }
    ini_setting { 'aws_access_key_id setting':
      ensure  => present,
      path    => $aws_cli_ini_settings,
      section => 'default',
      setting => 'aws_access_key_id',
      value   => $aws_access_key_id,
      require => File[$directory],
    }
    ini_setting { 'aws_secret_access_key setting':
      ensure  => present,
      path    => $aws_cli_ini_settings,
      section => 'default',
      setting => 'aws_secret_access_key',
      value   => $aws_secret_access_key,
      require => File[$directory],
    }

  }

}
