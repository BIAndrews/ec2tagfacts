require 'spec_helper'
describe 'ec2tagfacts' do

  context 'with defaults for all parameters' do
    it { should contain_class('ec2tagfacts') }
  end
end
