require 'spec_helper'
require 'fileutils'

RSpec.configure do |c|
  c.default_facts = {
    ':ec2_tag_facts::simfile' => '/tmp/ec2tagfacts_simulation.json.' + Process.pid.to_s
  }
end

describe "AWS tag simulation" do
  it 'write ec2tagfacts_simulation.json tmp file' do
    #
    #  For simulated EC2 tag facts
    #
    @filename = "/tmp/ec2tagfacts_simulation.json." + Process.pid.to_s
    @content = '{
    "Tags": [
        {
            "ResourceType": "instance",
            "ResourceId": "i-simulated",
            "Value": "sim-dev-rspec",
            "Key": "Env"
        },
        {
            "ResourceType": "instance",
            "ResourceId": "i-simulated",
            "Value": "sim-server1-rspec",
            "Key": "Name"
        },
        {
            "ResourceType": "instance",
            "ResourceId": "i-simulated",
            "Value": "bryanandrews@rspec",
            "Key": "Owner"
        }
    ]
}'
    dirname = File.dirname(@filename)
    unless File.directory?(dirname)
      FileUtils.mkdir_p(dirname)
    end
    File.open(@filename, 'w') {|f| f.write(@content) }
    expect(File.read(@filename)).to eq @content
  end
end

describe 'ec2tagfacts' do

  context 'supported operating systems with simulated tags' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "ec2tagfacts class without any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ec2tagfacts') }
          it { is_expected.to contain_class('ec2tagfacts::params') }
          it { is_expected.to contain_package('awscli') }
          it { is_expected.to contain_package('python-pip') }
          it { is_expected.to contain_package('ruby-json-package') }
          it { expect(Facter.fact('ec2_tag_owner').value).to eql("bryanandrews@rspec") }
          it { expect(Facter.fact('ec2_tag_name').value).to eql("sim-server1-rspec") }
          it { expect(Facter.fact('ec2_tag_env').value).to eql("sim-dev-rspec") }
          it { expect(Facter.fact(':ec2_tag_facts::simfile').value).to eql("/tmp/ec2tagfacts_simulation.json." + Process.pid.to_s) }
        end
      end
    end
  end

  context 'supported operating systems with key specified' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let(:params) do
          {
            'aws_access_key_id' => 'WASDWASDWASDWASDWASDWASD',
            'aws_secret_access_key' => 'FRJGI$&!(@H@KFQ@HQ@KFAFKNAANWKHDQ@',
          }
        end
        context "ec2tagfacts class with access key and secret any parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ec2tagfacts') }
          it { is_expected.to contain_class('ec2tagfacts::params') }
          it { is_expected.to contain_package('awscli') }
          it { is_expected.to contain_package('ruby-json-package') }
          it { is_expected.to contain_file('/root/.aws') }
          it { is_expected.to contain_ini_setting('aws_access_key_id setting') }
          it { is_expected.to contain_ini_setting('aws_secret_access_key setting') }
          it { expect(Facter.fact('ec2_tag_owner').value).to eql("bryanandrews@rspec") }
          it { expect(Facter.fact('ec2_tag_name').value).to eql("sim-server1-rspec") }
          it { expect(Facter.fact('ec2_tag_env').value).to eql("sim-dev-rspec") }
          it { expect(Facter.fact(':ec2_tag_facts::simfile').value).to eql("/tmp/ec2tagfacts_simulation.json." + Process.pid.to_s) }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'ec2tagfacts class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('ec2tagfacts') }.to raise_error(Puppet::Error, /Unsupported platform: Solaris\/Nexenta/) }
    end
  end
end

#
#  Temp file cleanup
#
describe "AWS tag simulation cleanup" do
  it 'remove ec2tagfacts_simulation.json tmp file' do
    @filename = "/tmp/ec2tagfacts_simulation.json." + Process.pid.to_s
    FileUtils.rm(@filename)
    #expect(@filename).not_to exist
    expect(File).not_to exist(@filename)
  end
end

