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

  # params definition
  let(:params) do
    {
      :enable_checksumfiles           => true,
      :enable_autouninstaller         => true,
      :enable_allowglobalconfirmation => true,
      :enable_failonautouninstaller   => true,
      :disable_default_source         => false,
      :sources                        => {},
    }
  end

  context 'when calling the class from outside the current module' do

    error_message = 'Class chocolatey::config is private'
    it "should fail with message #{error_message}" do
      expect { should compile }.to raise_error(/#{error_message}/)
    end
  end

  context 'on version < 0.9.9' do
    before :each do
      MockFunction.new('assert_private', {:type => :statement})
      facts.merge!(
        {
          :chocolateyversion => '0.9.8.31'
        }
      )
    end

    it { should contain_notify('features are ignored on chocolatey version < 0.9.9')}

    context 'when default source should be disabled' do
      before :each do
        params.merge!(
          {
            :disable_default_source => true
          }
        )
      end

      context 'and status is still disabled' do
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

        it { should contain_exec('add_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('remove_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('enable_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('disable_source_chocolatey').with(
               :onlyif => false
        )}

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

        it { should contain_exec('add_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('remove_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('enable_source_chocolatey').with(
               :onlyif => false
        )}

        it { should contain_exec('disable_source_chocolatey').with(
               :onlyif => true
        )}

      end
    end

  end

  context 'on version >= 0.9.9' do
    before :each do
      MockFunction.new('assert_private', {:type => :statement})
      facts.merge!(
        {
          :chocolateyversion => '0.9.9.8'
        }
      )
    end

    ## FEATURES
    context 'when enable is true on all features (params default)' do

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

          it { should contain_exec("enable_feature_#{feature_name}").with(
                 :onlyif => true
          )}

          it { should contain_exec("disable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

        end

      end

      context 'when feature status is enabled' do

        %W(checksumFiles autoUninstaller allowGlobalConfirmation failOnAutoUninstaller).each do |feature_name|
          it { should contain_chocolatey__config__feature(feature_name).with(
                 :feature_name => feature_name,
                 :enable       => true
          )}

          it { should contain_exec("enable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

          it { should contain_exec("disable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

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

          it { should contain_exec("enable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

          it { should contain_exec("disable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

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

          it { should contain_exec("enable_feature_#{feature_name}").with(
                 :onlyif => false
          )}

          it { should contain_exec("disable_feature_#{feature_name}").with(
                 :onlyif => true
          )}

        end

      end
    end
  end

end
