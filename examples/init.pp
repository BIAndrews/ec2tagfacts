#
# Example AWS IAM policy for read-only access to tags. The access_key_id must be able to read EC2 instance tags.
# Do you want to know more? http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-policies-ec2-console.html#ex-read-only
#
#{
#   "Version": "2012-10-17",
#   "Statement": [{
#      "Effect": "Allow",
#      "Action": [
#         "ec2:DescribeTags"
#      ],
#      "Resource": "*"
#   }
#   ]
#}

# /* Auto detect awscli package source and if it needs EPEL or not */
class { '::ec2tagfacts': }

# === Examples
#
#  /* Autodetect awscli tools provider installation */
#  class { '::ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#  }
#
#  /* Force pip provider installation */
#  class { '::ec2tagfacts':
#    aws_access_key_id => 'ASFJIJ3IGJ5JSKAJ',
#    aws_secret_access_key => 'svbasJAB254FHU6hsH5ujxfjdSs',
#    awscli_pkg => 'pip',
#    awscli => 'awscli',
#  }
#
#  /* Force yum provider installation and don't set an access key or secret since we use a Role */
#  class { '::ec2tagfacts':
#    awscli_pkg => 'yum',
#    awscli => 'awscli',
#  }
#
# /* Do not enable epel, autodetect awscli package source and name */
#  class { '::ec2tagfacts': 
#    enable_epel => false,
#  }

notify { "AWS EC2 name tag is ${::ec2_tag_name}": }
notify { "AWS EC2 structured tag is ${::ec2_tags}": }
notify { "AWS EC2 name tag from structured fact is ${::ec2_tags['name']}": }
