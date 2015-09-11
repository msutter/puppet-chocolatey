require 'spec_helper'

describe 'chocolatey::config::source', :type => 'define' do

  let (:title) { 'mysource' }

  let(:pre_condition) do
    "
    "
  end

  # facts definition
  let(:facts) do
    {
      :kernel => 'windows',
      :choco_install_path => 'C:\ProgramData\chocolatey',
    }
  end

  # params definition
  let(:params) do
    {
      :location => 'http://mysource/api/v2'
    }
  end

  context 'when ensure is present' do

    context 'and source does not exists' do
      before :each do
        facts.merge!(
          {
            :choco_sources => {}
          }
        )
      end
      context 'with user and password' do
        before :each do
          params.merge!(
            {
              :user_name => 'myuser',
              :password  => 'mypassword'
            }
          )
        end
        context 'and choco version is greater 0.9.9' do
          before :each do
            facts.merge!(
              {
                :chocolateyversion => '0.9.9.8'
              }
            )
          end

          it { should contain_chocolatey__config__source('mysource').with(
                 :ensure      => 'present',
                 :source_name => 'mysource',
                 :enable      => true,
                 :location    => 'http://mysource/api/v2',
                 :user_name   => 'myuser',
                 :password    => 'mypassword'
          )}

          it { should_not contain_exec('remove_source_mysource')}
          it { should contain_exec('add_source_mysource').with(
                 :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources add -name mysource -source http://mysource/api/v2 -user myuser -password mypassword',
          )}
        end # 'and choco version is greater 0.9.9'

        context 'and choco version is lesser 0.9.9' do
          before :each do
            facts.merge!(
              {
                :chocolateyversion => '0.9.8.31'
              }
            )
          end

          it { should contain_chocolatey__config__source('mysource').with(
                 :ensure      => 'present',
                 :source_name => 'mysource',
                 :enable      => true,
                 :location    => 'http://mysource/api/v2',
                 :user_name   => 'myuser',
                 :password    => 'mypassword'
          )}
          it { should contain_notify(
                 "Ignoring parameter 'user_name' which is supported on choco version < 0.9.9"
          )}
          it { should contain_notify(
                 "Ignoring parameter 'password' which is supported on choco version < 0.9.9"
          )}
          it { should_not contain_exec('remove_source_mysource')}
          it { should contain_exec('add_source_mysource').with(
                 :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources add -name mysource -source http://mysource/api/v2',
          )}

        end # 'and choco version is lesser 0.9.9'
      end # 'with user and password'
      context 'when enable is true' do
        before :each do
          params.merge!(
            {
              :enable => true,
            }
          )
        end
        it { should contain_exec('add_source_mysource')}
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

      end

      context 'when enable is false' do
        before :each do
          params.merge!(
            {
              :enable => false,
            }
          )
        end
        it { should contain_exec('add_source_mysource')}
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should contain_exec('disable_source_mysource')}


      end # 'when enable is false'
    end # 'and source does not exists'

    # Array of possible facts (with stringified facts)
    [
      "{\"mysource\"=>{\"location\"=>\"http://mysource/api/v2\", \"status\"=>\"Enabled\"}}",
      {
        'mysource' => {
          'location' => 'http://mysource/api/v2',
          'status'   => 'Enabled'
        }
      }
    ].each do |choco_sources_fact|
      context 'and source exists' do
        before :each do
          facts.merge!(
            {
              :choco_sources => choco_sources_fact
            }
          )
        end

        it { should contain_chocolatey__config__source('mysource').with(
               :ensure      => 'present',
               :source_name => 'mysource',
               :enable      => true,
               :location    => 'http://mysource/api/v2',
               :user_name   => nil,
               :password    => nil,
        )}


        it { should_not contain_exec('add_source_mysource')}
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

        context 'and location is not in sync' do
          before :each do
            params.merge!(
              {
                :location => 'http://mynewsource/api/v2',
              }
            )
          end

          it { should contain_chocolatey__config__source('mysource').with(
                 :ensure      => 'present',
                 :source_name => 'mysource',
                 :enable      => true,
                 :location    => 'http://mynewsource/api/v2',
                 :user_name   => nil,
                 :password    => nil,
          )}

          it { should contain_exec('remove_source_mysource').with(
                 :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources remove -name mysource',
                 :before => 'Exec[add_source_mysource]'
          )}

          it { should contain_exec('add_source_mysource').with(
                 :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources add -name mysource -source http://mynewsource/api/v2',
          )}
          it { should_not contain_exec('enable_source_mysource')}
          it { should_not contain_exec('disable_source_mysource')}

          context 'with user and password' do
            before :each do
              params.merge!(
                {
                  :user_name => 'myuser',
                  :password  => 'mypassword'
                }
              )
            end
            context 'and choco version is greater 0.9.9' do
              before :each do
                facts.merge!(
                  {
                    :chocolateyversion => '0.9.9.8'
                  }
                )
              end

              it { should contain_chocolatey__config__source('mysource').with(
                     :ensure      => 'present',
                     :source_name => 'mysource',
                     :enable      => true,
                     :location    => 'http://mynewsource/api/v2',
                     :user_name   => 'myuser',
                     :password    => 'mypassword'
              )}
              it { should contain_exec('remove_source_mysource').with(
                     :before => 'Exec[add_source_mysource]'
              )}
              it { should contain_exec('add_source_mysource').with(
                     :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources add -name mysource -source http://mynewsource/api/v2 -user myuser -password mypassword',
              )}
              it { should_not contain_exec('enable_source_mysource')}
              it { should_not contain_exec('disable_source_mysource')}

            end

            context 'and choco version is lesser 0.9.9' do
              before :each do
                facts.merge!(
                  {
                    :chocolateyversion => '0.9.8.31'
                  }
                )
              end

              it { should contain_chocolatey__config__source('mysource').with(
                     :ensure      => 'present',
                     :source_name => 'mysource',
                     :enable      => true,
                     :location    => 'http://mynewsource/api/v2',
                     :user_name   => 'myuser',
                     :password    => 'mypassword'
              )}
              it { should contain_notify(
                     "Ignoring parameter 'user_name' which is supported on choco version < 0.9.9"
              )}
              it { should contain_notify(
                     "Ignoring parameter 'password' which is supported on choco version < 0.9.9"
              )}
              it { should contain_exec('remove_source_mysource').with(
                     :before => 'Exec[add_source_mysource]'
              )}
              it { should contain_exec('add_source_mysource').with(
                     :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources add -name mysource -source http://mynewsource/api/v2',
              )}
              it { should_not contain_exec('enable_source_mysource')}
              it { should_not contain_exec('disable_source_mysource')}
            end
          end

        end # 'and location is not in sync'
        context 'when enable is true' do
          before :each do
            params.merge!(
              {
                :enable => true,
              }
            )
          end

          it { should_not contain_exec('add_source_mysource')}
          it { should_not contain_exec('remove_source_mysource')}
          it { should_not contain_exec('enable_source_mysource')}
          it { should_not contain_exec('disable_source_mysource')}

        end
      end # 'and source exists'
    end
  end # 'when ensure is present'

  context 'with ensure absent' do
    # define different facts for this scenario
    before :each do
      params.merge!(
        {
          :ensure => 'absent',
        }
      )
    end # 'with ensure absent'

    # Array of possible facts (with stringified facts)
    [
      "{\"mysource\"=>{\"location\"=>\"http://mysource/api/v2\", \"status\"=>\"Enabled\"}}",
      {
        'mysource' => {
          'location' => 'http://mysource/api/v2',
          'status'   => 'Enabled'
        }
      }
    ].each do |choco_sources_fact|

      context 'and source exists' do
        before :each do
          facts.merge!(
            {
              :choco_sources => choco_sources_fact
            }
          )
        end

        it { should contain_chocolatey__config__source('mysource').with(
               :ensure      => 'absent',
               :source_name => 'mysource',
               :enable      => true,
               :location    => 'http://mysource/api/v2',
               :user_name   => nil,
               :password    => nil,
        )}

        it { should_not contain_exec('add_source_mysource')}
        it { should contain_exec('remove_source_mysource').with(
               :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources remove -name mysource',
               :before => nil,
        )}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

      end
    end
  end

  context 'when enable is true' do
    before :each do
      params.merge!(
        {
          :enable => true,
        }
      )
    end

    context 'and source does not exists' do
      before :each do
        facts.merge!(
          {
            :choco_sources => {}
          }
        )
      end
      context 'and ensure is present' do

        it { should contain_exec('add_source_mysource')}
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}
      end

      context 'and ensure is absent' do
        before :each do
          params.merge!(
            {
              :ensure => 'absent',
            }
          )
        end # 'with ensure absent'

        it { should_not contain_exec('add_source_mysource')}
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

      end

    end

    context 'and source exists' do

      context 'and status is enabled' do
        before :each do
          facts.merge!(
            {
              :choco_sources => {
                'mysource' => {
                  'location' => 'http://mysource/api/v2',
                  'status'   => 'Enabled'

                }
              }
            }
          )
        end

        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('add_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

      end

      context 'and status is disabled' do
        before :each do
          facts.merge!(
            {
              :choco_sources => {
                'mysource' => {
                  'location' => 'http://mysource/api/v2',
                  'status'   => 'Disabled'
                }
              }
            }
          )
        end
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('add_source_mysource')}
        it { should contain_exec('enable_source_mysource').with(
               :command => 'C:\ProgramData\chocolatey\bin\choco.exe sources enable -name mysource',
        )}
        it { should_not contain_exec('disable_source_mysource')}

      end # 'and location is not in sync'
    end # 'and source exists'

  end # 'when enable is true'

  context 'when enable is false' do
    before :each do
      params.merge!(
        {
          :enable => false,
        }
      )
    end

    context 'and source does not exists' do
      before :each do
        facts.merge!(
          {
            :choco_sources => {}
          }
        )
      end
      it { should_not contain_exec('remove_source_mysource')}
      it { should contain_exec('add_source_mysource')}
      it { should_not contain_exec('enable_source_mysource')}
      it { should contain_exec('disable_source_mysource')}

    end

    context 'and source exists' do

      context 'and status is enabled' do
        before :each do
          facts.merge!(
            {
              :choco_sources => {
                'mysource' => {
                  'location' => 'http://mysource/api/v2',
                  'status'   => 'Enabled'

                }
              }
            }
          )
        end
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('add_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should contain_exec('disable_source_mysource').with(
               :before => nil
        )}
      end

      context 'and status is disabled' do
        before :each do
          facts.merge!(
            {
              :choco_sources => {
                'mysource' => {
                  'location' => 'http://mysource/api/v2',
                  'status'   => 'Disabled'
                }
              }
            }
          )
        end
        it { should_not contain_exec('remove_source_mysource')}
        it { should_not contain_exec('add_source_mysource')}
        it { should_not contain_exec('enable_source_mysource')}
        it { should_not contain_exec('disable_source_mysource')}

      end # 'and location is not in sync'
    end # 'and source exists'

  end # 'when enable is false'
end
