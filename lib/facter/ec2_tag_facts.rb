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
#
# AWS Tag Simulation:
#   Create the file /etc/puppetlabs/ec2tagfacts_simulation.json like this:
#
#{
#    "Tags": [
#        {
#            "ResourceType": "instance", 
#            "ResourceId": "i-simulation", 
#            "Value": "dev", 
#            "Key": "Env"
#        }, 
#        {
#            "ResourceType": "instance", 
#            "ResourceId": "i-simulation", 
#            "Value": "server1", 
#            "Key": "Name"
#        }, 
#        {
#            "ResourceType": "instance", 
#            "ResourceId": "i-simulation", 
#            "Value": "bryanandrews@gmail", 
#            "Key": "Owner"
#        }
#    ]
#}
#
#
require "net/http"
require 'json' # hint: yum install ruby-json, or apt-get install ruby-json
require "uri"
require "date"
require 'puppet'

# if set, file will be appended to with debug data
$debug = "/tmp/ec2_tag_facts.log"

# if this exists we simulate the AWS API tags
simfile          = Facter.value(':ec2_tag_facts::simfile')
simfile_failsafe = "/etc/puppetlabs/ec2tagfacts_simulation.json"

################################################
#
# void debug_msg ( string txt )
#
# Dump debug messages if debug is set
#

def debug_msg(txt)
  if $debug.is_a? String
    File.open($debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " " + txt + "\n") }
  end
end

################################################
#
# bool valid_json ( string json )
#
# Verify a string is valid JSON
#

def valid_json?(json)
  begin
    JSON.parse(json)
    return true
  rescue JSON::ParserError => e
    return false
  end
end

####################################################
#
# Start
#
if !simfile.is_a? String then
  # no hiera variable found. Use hardcoded failsafe.
  simfile = simfile_failsafe
end

debug_msg("Checking for simulation file: " + simfile)

if Pathname.new(simfile).file? then

  debug_msg("Using simulation file: " + simfile)

  #
  # Simulated data as if we got it from AWS
  #
  instance_id = "i-simulation"               # pretend instance ID
  region      = "us-simulation-3"            # pretend region
  jsonString  = File.open(simfile).read      # read the file in as string

else

  debug_msg("Using live AWS API: http://169.254.169.254")

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

end

if !instance_id.is_a? String then

  # We couldn't find an instance string. Not an EC2 instance?

  debug_msg("Something bad happened since there was no error but instance_id isn't a string.")

else

   # We have an instance ID we continue on...

  ##############################################################################################
  #
  # Get the AWS EC2 instance region from http://instance-data/ and then shorten the region
  # for example we convert us-west-2b into us-west-2 in order to get the tags.
  #

  if !region.is_a? String then

    request2 = Net::HTTP::Get.new("/latest/meta-data/placement/availability-zone")
    response2 = http.request(request2)
    r = response2.body

    region = /.*-.*-[0-9]/.match(r)

  end

  debug_msg("Region is #{region}")

  ###########################################################
  #
  # Get the aws ec2 instance tags as a JSON string
  #

  begin

    # This is why aws cli is required
    if !jsonString.is_a? String then
      jsonString = `aws ec2 describe-tags --filters "Name=resource-id,Values=#{instance_id}" --region #{region} --output json`
    else
      debug_msg("Using existing jsonString")
    end

    if !valid_json?(jsonString) then
      msg = "ERROR: jsonString contains invalid JSON"
      debug_msg(msg)
      abort # exit now
    end

    debug_msg("JSON is...\n#{jsonString}")

    # convert json string to hash
    hash = JSON.parse(jsonString)

    if hash.is_a? Hash then

      debug_msg("Hash of tags found")

      if hash.has_key?("Tags") then

        result = {}

        ################################################################################
        #
        # Loop through all tags
        #

        hash['Tags'].each do |child|

          # Name it and make sure its lower case and convert spaces to understores
          name = child['Key'].to_s
          name.downcase!
          name.gsub!(/\W+/, "_")
          fact = "ec2_tag_#{name}"

          debug_msg("Setting fact #{fact} to #{child['Value']}")

          # append to the hash for structured fact later
          result[name] = child['Value']

          debug_msg("Added #{fact} to results hash for structured fact")

          # set puppet fact - flat version
          Facter.add("#{fact}") do
            setcode do
              child['Value']
            end
          end

        end

        ################################################################################
        #
        # Set structured fact
        #

        if defined?(result) != nil
          Facter.add(:ec2_tags) do
            setcode do
              result
            end
          end
        end

        debug_msg("Structured fact is: #{result}")

      else

        debug_msg("No tags found")

      end

    end

  rescue # Ignore if awscli had any issues

    debug_msg("awscli exec failed")

  end
end
