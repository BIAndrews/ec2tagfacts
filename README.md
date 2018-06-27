# ec2tagfacts

[![Build Status](https://travis-ci.org/BIAndrews/ec2tagfacts.svg?branch=master)](https://travis-ci.org/BIAndrews/ec2tagfacts)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/bryana/ec2tagfacts.svg)](https://forge.puppet.com/bryana/ec2tagfacts)
[![Code Climate](https://codeclimate.com/github/BIAndrews/ec2tagfacts/badges/gpa.svg)](https://codeclimate.com/github/BIAndrews/ec2tagfacts)

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with ec2tagfacts](#setup)
    * [What ec2tagfacts affects](#what-ec2tagfacts-affects)
    * [Setup requirements](#setup-requirements)
    * [AWS IAM Role](#aws-iam-role)
    * [AWS IAM Policy](#aws-iam-policy)
    * [R10k Example](#r10k-example)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [RSpec Testing - Automated QA tests](#rspec-testing)
    * [OS Support](#os-support)
6. [Change Log](#change-log)
7. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This turns EC2 instance tags into puppet facts. For example: `$::ec2_tag_tagname` and structured as `$::ec2_tags['tagname']`. 

## Setup

### What ec2tagfacts affects

* Tag names are prepended with `ec2_tag_`, converted to all lowercase, and non-word character are converted to underscores.
* Tags are also available as a structured fact called `ec2_tags`
* You can now use EC2 tags in puppet classes, for example `$::ec2_tag_name` or `$::ec2_tags['name']`.
* EC2 tags are then added to facter.
* Python pip is installed in order to install the aws cli tool with pip if pip is the provider for your platform. For example CentOS7 epel provides awscli so that us used.
* The AWS cli python package is installed.
* Optionally provided AWS credentials are set in the /root/.aws/credentials INI file. Role access method is preferred.
* EPEL is required for RHEL based systems and is automatically setup on them unless you disable that feature.

### Setup Requirements

The most secure and preferred method is to use IAM Roles. This allows the AWS cli tool to read EC2 tags without exposing a key+secret on the filesystem. If this is a new instance you are just now launching I recommend using an IAM Role. If this is an existing system you can not assign IAM Roles to launched EC2 instances so you will need to use an IAM key+secret pair. AWS credentials with read access to EC2 tags are optional parameters or from hiera or class parameters. EPEL is required for RHEL based systems for python-pip package support and is automatically setup when that OS family is detected.

### AWS IAM Role

_This is the most secure and preferred method._

Console -> Identity & Access Management -> Roles -> Create New Role -> Role Name Example: `WebServer1` -> Select `Amazon EC2` -> Next Step -> Create Role -> Edit Role created -> Inline Policy / Create Role Policy -> Custom Policy -> Policy Name Example: ec2tagread -> Policy Document ->
~~~
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
~~~
-> Apply Policy

Now when you launch EC2 instances make sure you select this `Role` to launch them into. Once launched an EC2 instance can't be added to a role or removed from a role but the contents of the roles' policies can be changed at any time.

### AWS IAM Policy

This is the option available to existing EC2 instance without Role assignments. The AWS access_key you use must be given rights to read ec2 tags. Here is an example of a small read-only ec2 tag policy. This is a less secure alternative because the secret+key are exposed on the filesystem. However the AWS cli ini file is owned by root and only readable by root.

~~~
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeTags"
      ],
      "Resource": "*"
   }
   ]
}
~~~

### R10k Example

Add this to your `Puppetfile`:
~~~
mod 'bryana/ec2tagfacts', :latest
mod 'puppetlabs-stdlib', :latest
mod 'stahnma/epel', :latest
mod 'puppetlabs/inifile', :latest
~~~

## Usage

### Class with parameters

#### Role Method ####
~~~
class { '::ec2tagfacts': }
~~~

#### Access Key Method ####
~~~
class { '::ec2tagfacts':
  aws_access_key_id      => 'ASJSF34782SJGU',
  aws_secret_access_key  => 'SJG34861gaKHKaDfjq29gfASf427RGHSgesge',
}
~~~

### Hiera Example

This is only needed on instances without a `Role` providing the tag read rights. The `Role` method should be used whenever possible.

~~~
ec2tagfacts::aws_access_key_id: 'ASJSF34782SJGU'
ec2tagfacts::aws_secret_access_key: 'SJG34861gaKHKaDfjq29gfASf427RGHSgesge'
~~~

Then include the class like this:
~~~
include ec2tagfacts
~~~

## Reference

###Classes

####Public classes
* `ec2tagfacts`: Installs and configures aws cli and loads EC2 tags as facts in facter.

####Private classes
* `ec2tagfacts::params`: Auto detection of package names based on OS family.

###Parameters

#####`aws_access_key_id`

Optional. Specify the AWS access_key_id with read rights to EC2 tags.

#####`aws_secret_access_key`

Optional. Specify the AWS access_key_id's secret.

#####`aws_cli_ini_settings`

Optional. Change the location of the AWS cli credential ini file. Full path expected.

#####`enable_epel`

Optional. True/false. Autodetected in ec2tagfacts::params based on OS family. You can override that with the parameter or in hiera.

#####`pippkg`

Optional. String/false. Autodetected in ec2tagfacts::params based on OS family. You can override that with the parameter or in hiera. This is the python-pip package name to install. False disables installation. Python pip is used to install awscli which is required.

#####`awscli_pkg`

Optional. String. Autodetected in ec2tagfacts::params based on OS family. You can override that with the parameter or in hiera. This is the awscli package provider to use. Python pip is used to install awscli unless a platform package is available.

#####`rubyjsonpkg`

Optional. String. Autodetected in ec2tagfacts::params based on OS family. You can override that with the parameter or in hiera. This is the Ruby JSON package name to use. To disable
management of this package, set to false.


## RSpec Testing

If bundle isn't already installed it is generally installed with `gem install bundle`.

```
bundle install
rake spec
```

TravisCI is currently testing 25 ruby+puppet environments on 49 OS flavor+parameter combinations. This is `1,225` tests per QA cycle.

### OS Support

* RedHat 5
* RedHat 6
* RedHat 7
* CentOS 5
* CentOS 6
* CentOS 7
* Debian 6
* Debian 7
* Debian 8
* OracleLinux 6
* OracleLinux 7
* Scientific Linux 5
* Scientific Linux 6
* Scientific Linux 7
* SLES 10
* SLES 11
* SLES 12
* Ubuntu 10
* Ubuntu 12
* Ubuntu 14
* Ubuntu 15
* Ubuntu 16
* Gentoo - _experimental_
* Amazon Linux 2014 - _rspec nodeset not available for automated testing_
* Amazon Linux 2015 - _rspec nodeset not available for automated testing_
* Amazon Linux 2016 - _rspec nodeset not available for automated testing however this is the development reference platform_

## Change Log

* `v0.2.0` - Added structured facts. Better support on platforms for using pip package or platform package.
* `v0.1.x` - Initial release

## Limitations

This is written for both CentOS/RHEL/Amazon based systems and Debian/Ubuntu based systems. EPEL is required for the RHEL family in order to obtain the python-pip package to install the AWS cli pip package and is automatically detected and setup. 

