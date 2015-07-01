#
# Example AWS IAM policy for read-only access to tags. The access_key_id must be able to read EC2 instance tags.
# Do you want to know more? http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-policies-ec2-console.html#ex-read-only
#
#{
#   "Version": "2012-10-17",
#   "Statement": [{
#      "Effect": "Allow",
#      "Action": [
#         "ec2:DescribeInstances", "ec2:DescribeImages",
#         "ec2:DescribeTags", "ec2:DescribeSnapshots"
#      ],
#      "Resource": "*"
#   }
#   ]
#}

class { 'ec2tagfacts':
}

notify { "AWS EC2 name tag is $::ec2_tag_name": }
