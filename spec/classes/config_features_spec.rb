require 'spec_helper'

describe 'chocolatey', :type => 'class' do

  let(:pre_condition) do
    "
    "
  end

  # params definition
  let(:params) do
    {
      :disable_default_source         => false,
      :sources                        => {}
    }
  end

  # facts definition
  let(:facts) do
    {
      :kernel             => 'windows',
      :choco_install_path => 'C:\ProgramData\chocolatey',
      :chocolateyversion  => '0.9.9.8',
      :choco_features     => {
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

  context 'on version < 0.9.9' do
    before :each do
      facts.merge!(
        {
          :chocolateyversion => '0.9.8.31'
        }
      )
    end

    it { should contain_notify('features are ignored on chocolatey version < 0.9.9')}

  end

  context 'on version >= 0.9.9' do
    before :each do
      facts.merge!(
        {
          :chocolateyversion => '0.9.9.8'
        }
      )
    end

    ## FEATURES
    context 'when enable is true on all features (params default)' do
      before :each do
        params.merge!(
          {
            :enable_checksumfiles           => true,
            :enable_autouninstaller         => true,
            :enable_allowglobalconfirmation => true,
            :enable_failonautouninstaller   => true,
          }
        )
      end
      context 'when feature status is disabled' do
        before :each do
          facts.merge!(
            {
              :choco_features => {
                'checksumFiles' => {
                  'status' => 'Disabled'
                },
                'autoUninstaller' => {
                  'status' => 'Disabled'
                },
                'allowGlobalConfirmation' => {
                  'status' => 'Disabled'
                },
                'failOnAutoUninstaller' => {
                  'status' => 'Disabled'
                },
              }
            }
          )
        end

        %W(checksumFiles autoUninstaller allowGlobalConfirmation failOnAutoUninstaller).each do |feature_name|
          it { should contain_chocolatey__config__feature(feature_name).with(
                 :feature_name => feature_name,
                 :enable       => true
          )}
          it { should contain_exec("enable_feature_#{feature_name}")}
          it { should_not contain_exec("disable_feature_#{feature_name}")}
        end

      end

      context 'when feature status is enabled' do

        %W(checksumFiles autoUninstaller allowGlobalConfirmation failOnAutoUninstaller).each do |feature_name|
          it { should contain_chocolatey__config__feature(feature_name).with(
                 :feature_name => feature_name,
                 :enable       => true
          )}
          it { should_not contain_exec("enable_feature_#{feature_name}")}
          it { should_not contain_exec("disable_feature_#{feature_name}")}
        end

      end
    end

    context 'when enable is false' do
      before :each do
        params.merge!(
          {
            :enable_checksumfiles           => false,
            :enable_autouninstaller         => false,
            :enable_allowglobalconfirmation => false,
            :enable_failonautouninstaller   => false,
          }
        )
      end

      context 'when feature status is disabled' do
        before :each do
          facts.merge!(
            {
              :choco_features => {
                'checksumFiles' => {
                  'status' => 'Disabled'
                },
                'autoUninstaller' => {
                  'status' => 'Disabled'
                },
                'allowGlobalConfirmation' => {
                  'status' => 'Disabled'
                },
                'failOnAutoUninstaller' => {
                  'status' => 'Disabled'
                },
              }
            }
          )
        end

        %W(checksumFiles autoUninstaller allowGlobalConfirmation failOnAutoUninstaller).each do |feature_name|
          it { should contain_chocolatey__config__feature(feature_name).with(
                 :feature_name => feature_name,
                 :enable       => false
          )}
          it { should_not contain_exec("enable_feature_#{feature_name}")}
          it { should_not contain_exec("disable_feature_#{feature_name}")}
        end

      end

      context 'when feature status is enabled' do
        before :each do
          facts.merge!(
            {
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
              }
            }
          )
        end

        %W(checksumFiles autoUninstaller allowGlobalConfirmation failOnAutoUninstaller).each do |feature_name|
          it { should contain_chocolatey__config__feature(feature_name).with(
                 :feature_name => feature_name,
                 :enable       => false
          )}
          it { should_not contain_exec("enable_feature_#{feature_name}")}
          it { should contain_exec("disable_feature_#{feature_name}")}
        end

      end
    end
  end

end
