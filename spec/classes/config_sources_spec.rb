require 'spec_helper'

describe 'chocolatey', :type => 'class' do

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

  context 'when default source should be disabled' do
    before :each do
      params.merge!(
        {
          :disable_default_source => true,
        }
      )
    end

    context 'and status is already disabled' do
      before :each do
        facts.merge!(
          {
            :choco_sources => {
              'chocolatey' => {
                'location' => 'https://chocolatey.org/api/v2',
                'status'   => 'Disabled',
              },
            },
          }
        )
      end

      it { should contain_chocolatey__config__source('chocolatey').with(
             :enable => false
      )}
      it { should_not contain_exec('add_source_chocolatey')}
      it { should_not contain_exec('remove_source_chocolatey')}
      it { should_not contain_exec('enable_source_chocolatey')}
      it { should_not contain_exec('disable_source_chocolatey')}

    end
    context 'and status is enabled' do
      before :each do
        facts.merge!(
          {
            :choco_sources => {
              'chocolatey' => {
                'location' => 'https://chocolatey.org/api/v2',
                'status'   => 'Enabled',
              },
            },
          }
        )
      end

      it { should contain_chocolatey__config__source('chocolatey').with(
             :enable => false
      )}
      it { should_not contain_exec('add_source_chocolatey')}
      it { should_not contain_exec('remove_source_chocolatey')}
      it { should_not contain_exec('enable_source_chocolatey')}
      it { should contain_exec('disable_source_chocolatey').with(
             :before => nil
      )}

    end
  end

  context 'with custom sources' do

    it { should contain_chocolatey__config__source('mycustomsource').with(
           :ensure      => 'present',
           :source_name => 'mycustomsource',
           :enable      => true,
           :location    => 'http://mycustomsource.com/api/v2',
           :user_name   => nil,
           :password    => nil,
    )}


    it { should_not contain_exec('remove_source_mycustomsource')}
    it { should contain_exec('add_source_mycustomsource').with(
           :before => nil
    )}
    it { should_not contain_exec('enable_source_mycustomsource')}
    it { should_not contain_exec('disable_source_mycustomsource')}

  end
end
