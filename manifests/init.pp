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
# [*manage_awscli*]
#   True to have this module manage awscli installation, false not to. If false
#   awscli must be installed by other means.
#
# [*enable_epel*]
#   True to enable EPEL automatically, false not to. Automatically set in 
#   ec2tagfacts::params based on OS family.
#
# [*pippkg*]
#   Set in ec2tagfacts::params, this is the Python pip package name by OS 
#   family. False disables python pip package management.
#
# [*awscli*]
#   Set in ec2tagfacts::params, this is the pip package name of awscli.
#
# [*rubyjsonpkg*]
#   Set in ec2tagfacts::params, this is the ruby-json package name.
#   False disables ruby-json package package management.
#
# === Examples
#
#  /* Autodetect awscli tools provider installation */
#  class { 'ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#  }
#
#  /* Force pip provider installation */
#  class { 'ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#    awscli_pkg => 'pip',
#    awscli => 'awscli',
#  }
#
#  /* Force yum provider installation and don't set an access key or secret since we use a Role */
#  class { 'ec2tagfacts':
#    awscli_pkg => 'yum',
#    awscli => 'awscli',
#  }
#
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
  $manage_awscli          = true,
  $enable_epel            = $ec2tagfacts::params::enable_epel,
  $pippkg                 = $ec2tagfacts::params::pippkg,
  $awscli                 = $ec2tagfacts::params::awscli,
  $rubyjsonpkg            = $ec2tagfacts::params::rubyjsonpkg,
  $awscli_pkg             = $ec2tagfacts::params::awscli_pkg,

) inherits ec2tagfacts::params {


  if (!is_string($aws_access_key_id)) {
    fail('ERROR: ec2tagfacts::aws_access_key_id must be a string')
  }

  if (!is_string($aws_secret_access_key)) {
    fail('ERROR: ec2tagfacts::aws_secret_access_key must be a string')
  }

  if $manage_awscli {
    if $enable_epel {
      include ::epel
    }

    if $pippkg != false {

      if $enable_epel {
        Class['epel'] -> Package[$pippkg]
      }

      package { $pippkg:
        ensure => 'installed',
      }

      package { $awscli:
        ensure   => 'installed',
        provider => $awscli_pkg,
        require  => Package[$pippkg],
      }

    } else {

      package { $awscli:
        ensure   => 'installed',
        provider => $awscli_pkg,
      }

    }
  }

  if $rubyjsonpkg != false {
    package { 'ruby-json-package':
      ensure => 'installed',
      name   => $rubyjsonpkg,
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
