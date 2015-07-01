# ec2tagfacts

#### Table of Contents

1. [Overview](#overview)
2. [Setup - The basics of getting started with ec2tagfacts](#setup)
    * [What ec2tagfacts affects](#what-ec2tagfacts-affects)
    * [Setup requirements](#setup-requirements)
    * [AWS IAM Policy](#aws-iam-policy)
    * [R10k Example](#r10k-example)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This turns EC2 instance tags into puppet facts. For example: `ec2_tag_*tagname*`. 

## Setup

### What ec2tagfacts affects

* Tag names are prepended with `ec2_tag_`, converted to all lowercase, and spaces are converted to underscores.
* You can now use EC2 tags in puppet classes, for example `$::ec2_tag_name`.
* EC2 tags are then added to facter.
* Python pip is installed in order to install the aws cli tool with pip.
* The AWS cli python package is installed.
* Provided AWS credentials are set in the /root/.aws/credentials INI file.
* EPEL is required for RHEL based systems and is automatically setup on them unless you disable that feature.

### Setup Requirements

AWS credentials with read access to EC2 tags are required as parameters or from hiera. EPEL is required for RHEL based systems for python-pip package support and is automatically setup when that OS family is detected.

### AWS IAM Policy

The AWS access_key you use must be given rights to read ec2 tags. Here is an example of a small read-only ec2 tag policy.

~~~
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeInstances", "ec2:DescribeImages",
         "ec2:DescribeTags", "ec2:DescribeSnapshots"
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
mod 'stahnma/epel', :latest
~~~

## Usage

### Class with parameters
~~~
class { 'ec2tagfacts':
  aws_access_key_id      => 'ASJSF34782SJGU',
  aws_secret_access_key  => 'SJG34861gaKHKaDfjq29gfASf427RGHSgesge',
}
~~~

### Hiera Example
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

Specify the AWS access_key_id with read rights to EC2 tags.

#####`aws_secret_access_key`

Specify the AWS access_key_id's secret.

#####`aws_cli_ini_settings`

Optional. Change the location of the AWS cli credential ini file. Full path expected.

#####`enable_epel`

Optional. True/false setting. Autodetected in ec2tagfacts::params based on OS family. You can override that with the parameter or in hiera.

## Limitations

This is written for both CentOS/RHEL based systems and Debian/Ubuntu based systems. EPEL is required for the RHEL family in order to obtain the python-pip package to install the AWS cli pip package and is automatically detected and setup. 

