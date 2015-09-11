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

  context 'when calling the class from outside the current module' do

    error_message = 'Class chocolatey::config is private'
    it "should fail with message #{error_message}" do
      expect { should compile }.to raise_error(/#{error_message}/)
    end
  end

end