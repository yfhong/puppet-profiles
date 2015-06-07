require 'spec_helper'

describe 'profiles' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "profiles class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('profiles::params') }
          it { is_expected.to contain_class('profiles::install').that_comes_before('profiles::config') }
          it { is_expected.to contain_class('profiles::config') }
          it { is_expected.to contain_class('profiles::service').that_subscribes_to('profiles::config') }

          it { is_expected.to contain_service('profiles') }
          it { is_expected.to contain_package('profiles').with_ensure('present') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'profiles class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('profiles') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
