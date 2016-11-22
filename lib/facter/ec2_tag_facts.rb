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
require 'json'    # hint: yum install ruby-json, or apt-get install ruby-json
require "uri"
require "date"

################################################################
#
# Get the AWS EC2 instance ID from http://instance-data/
#

# if set, file will be appended to with debug data
#debug = "/tmp/ec2_tag_facts.log"

begin
  uri = URI.parse("http://169.254.169.254")
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = 4
  http.read_timeout = 4
  request = Net::HTTP::Get.new("/latest/meta-data/instance-id")
  response = http.request(request)

  instance_id = response.body

  if (defined?(debug)) != nil
    File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Instance ID is #{instance_id}\n") }
  end

rescue

  if (defined?(debug)) != nil
    File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " This is not an AWS EC2 instance or unable to contact the AWS instance-data web server.\n") }
  end

end


if !instance_id.is_a? String then

  # we couldnt find an instance string, exit not. Not an EC2 instance?

  if (defined?(debug)) != nil
    File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Something bad happened since there was no error but this isn't a string.\n") }
  end

else

   # if we have an instance ID we continue on...

  ##############################################################################################
  #
  # Get the AWS EC2 instance region from http://instance-data/ and then shorten the region
  # for example we convert us-west-2b into us-west-2 in order to get the tags
  #

  request2 = Net::HTTP::Get.new("/latest/meta-data/placement/availability-zone")
  response2 = http.request(request2)
  r = response2.body

  region = /.*-.*-[0-9]/.match(r)

  if (defined?(debug)) != nil  
    File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Region is #{region}\n") }
  end

  ###########################################################
  #
  # Get the aws ec2 instance tags as a JSON string
  #

  begin

    jsonString = `aws ec2 describe-tags --filters "Name=resource-id,Values=#{instance_id}" --region #{region} --output json`

    if (defined?(debug)) != nil
      File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " JSON is...\n#{jsonString}\n") }
    end

    # convert json string to hash
    hash = JSON.parse(jsonString)

    if hash.is_a? Hash then

      if (defined?(debug)) != nil
        File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Hash of tags found\n") }
      end

      if hash.has_key?("Tags") then

        result = {}

        ################################################################################
        #
        # Loop through all tags
        #

        hash['Tags'].each do |child|

          # Name it and make sure its lower case and convert spaces to understores
          name = "#{child['Key']}"
          name.downcase!
          name.gsub!(/\W+/, "_")
          fact = "ec2_tag_#{name}"

          if (defined?(debug)) != nil
            File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Setting fact #{fact} to #{child['Value']}\n") }
          end

          # append to the hash for structured fact later
          result["#{name}"] = child['Value']

          if (defined?(debug)) != nil
            File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Added #{fact} to results hash for structured fact\n") }
          end

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

        if (defined?(result)) != nil
          Facter.add(:ec2_tags) do
            setcode do
              result
            end
          end
        end

        if (defined?(debug)) != nil
          File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " Structured fact result is: #{result}\n") }
        end

      else

        if (defined?(debug)) != nil
          File.open(debug, 'a') { |file| file.write(Time.now.strftime("%Y/%m/%d %H:%M") + " No tags found\n") }
        end

      end

    end
  rescue # Ignore if awscli had any issues
  end

end
