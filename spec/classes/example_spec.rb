require 'spec_helper'

describe 'ec2tagfacts' do
  context 'supported operating systems' do
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
          it { is_expected.to contain_package('ruby-json-package') }
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
        end
      end
    end
  end

  context 'supported operating systems disable rubyjsonpkg mgmt' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end
        let(:params) do
          {
            'rubyjsonpkg' => false,
          }
        end
        context "ec2tagfacts class disable rubyjsonpkg mgmt" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('ec2tagfacts') }
          it { is_expected.to contain_class('ec2tagfacts::params') }
          it { is_expected.to contain_package('awscli') }
          it { is_expected.not_to contain_package('ruby-json-package') }
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
