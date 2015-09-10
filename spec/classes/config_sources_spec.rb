require 'spec_helper'

describe 'chocolatey::config', :type => 'class' do

  let(:pre_condition) do
    "
    "
  end

  # facts definition
  let(:facts) do
    {
      :kernel             => 'windows',
      :choco_install_path => 'C:\ProgramData\chocolatey',
      :chocolateyversion      => '0.9.9.8',
      :choco_features => {
        'checksumFiles' => {
          'status' => 'Enabled'
        },
        'autoUninstaller' => {
          'status' => 'Enabled'
        },
        'allowGlobalConfirmation' => {
          'status' => 'Enabled'
        },
        'failOnAutoUninstaller' => {
          'status' => 'Enabled'
        },
      },
      :choco_sources => {
        'chocolatey' => {
          'location' => 'https://chocolatey.org/api/v2',
          'status'   => 'Enabled',
        },
      },
    }
  end

  # params definition
  let(:params) do
    {
      :enable_checksumfiles           => true,
      :enable_autouninstaller         => true,
      :enable_allowglobalconfirmation => true,
      :enable_failonautouninstaller   => true,
      :disable_default_source         => false,
      :sources                        => {
        'mycustomsource' => {
          'location' => 'http://mycustomsource.com/api/v2',
        }
      },
    }
  end

  context 'when calling the class from outside the current module' do

    error_message = 'Class chocolatey::config is private'
    it "should fail with message #{error_message}" do
      expect { should compile }.to raise_error(/#{error_message}/)
    end
  end

  context 'with custom sources' do
    before :each do
      MockFunction.new('assert_private', {:type => :statement})
    end

    it { should contain_chocolatey__config__source('mycustomsource').with(
           :ensure      => 'present',
           :source_name => 'mycustomsource',
           :enable      => true,
           :location    => 'http://mycustomsource.com/api/v2',
           :user_name   => nil,
           :password    => nil,
    )}


    it { should contain_exec('remove_source_mycustomsource').with(
           :onlyif => false,
           :before => 'Exec[add_source_mycustomsource]'
    )}

    it { should contain_exec('add_source_mycustomsource').with(
           :onlyif => true,
           :before => 'Exec[enable_source_mycustomsource]'
    )}

    it { should contain_exec('enable_source_mycustomsource').with(
           :onlyif => false,
           :before => 'Exec[disable_source_mycustomsource]'
    )}

    it { should contain_exec('disable_source_mycustomsource').with(
           :onlyif => false,
    )}

  end
end
