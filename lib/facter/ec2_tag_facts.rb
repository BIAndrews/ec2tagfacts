# Fact: ec2_tag_facts
#
# Purpose:
#   Set AWS EC2 instance tags as facts.
#
# Source:
#   https://github.com/BIAndrews/ec2tagfacts
#
# Author:
#   Bryan Andrews (https://bryanandrews.org)

require "net/http"
require 'json' # hint: yum install ruby-json, or apt-get install ruby-json
require "uri"
require "date"
require 'aws-sdk'


# if set, file will be appended to with debug data
if Facter.value('operatingsystem') == 'windows'
  $debug = 'c:\temp\ec2_tag_facts.log'
else
  $debug = "/tmp/ec2_tag_facts.log"
end



#
# void debug_msg ( string txt )
#
# Used to dump debug messages if debug is set
#

def debug_msg(txt)
  if $debug.is_a? String
    File.open($debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " " + txt + "\n") }
  end
end

####################################################
#
# Start
#

begin

  ################################################################
  #
  # Get the AWS EC2 instance ID from http://169.254.169.254/
  #

  uri = URI.parse("http://169.254.169.254")
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = 4
  http.read_timeout = 4
  request = Net::HTTP::Get.new("/latest/meta-data/instance-id")
  response = http.request(request)
  instance_id = response.body

  debug_msg("Instance ID is #{instance_id}")

rescue

  debug_msg("This is not an AWS EC2 instance or unable to contact the AWS instance-data web server.")

end


if !instance_id.is_a? String then

  # We couldn't find an instance string. Not an EC2 instance?

  debug_msg("Something bad happened since there was no error but this isn't a string.")

else

   # We have an instance ID we continue on...

  ##############################################################################################
  #
  # Get the AWS EC2 instance region from http://instance-data/ and then shorten the region
  # for example we convert us-west-2b into us-west-2 in order to get the tags.
  #

  request2 = Net::HTTP::Get.new("/latest/meta-data/placement/availability-zone")
  response2 = http.request(request2)
  r = response2.body

  region = r.chop

  debug_msg("Region is #{region}")
  ec2 = Aws::EC2::Client.new(region: region)
  instance = ec2.describe_instances(instance_ids: [instance_id])
  tags = instance.reservations[0].instances[0].tags

#
# Loop through all tags
#

  result = {}
  tags.each do |tag|
          # Name it and make sure its lower case and convert spaces to understores
          name = tag['key'].to_s.downcase
          name.gsub!(/\W+/, "_")
          fact = "ec2_tag_#{name}"
          debug_msg("Setting fact #{fact} to #{tag['value']}")


          # append to the hash for structured fact later
          result[name] = tag['value']

          debug_msg("Added #{fact} to results hash for structured fact")

          # set puppet fact - flat version
          Facter.add("#{fact}") do
            setcode do
              tag['value']
            end
          end
  

        if defined?(result) != nil
          Facter.add(:ec2_tags) do
            setcode do
              result
            end
          end
        end

        debug_msg("Structured fact is: #{result}")
  end


end
