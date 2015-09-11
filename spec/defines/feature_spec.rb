require 'spec_helper'

describe 'chocolatey::config::feature', :type => 'define' do

  let (:title) { 'myfeature' }

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
      :choco_features     => {},
    }
  end

  # params definition
  let(:params) do
    {}
  end


  context 'when enable is true' do
    before :each do
      params.merge!(
        {
          :enable => true,
        }
      )
    end

    # Array of possible facts (with stringified facts)
    [
      "{\"myfeature\"=>{\"status\"=>\"Disabled\"}}",
      {
        'myfeature' => {
          'status' => 'Disabled'
        }
      },
    ].each do |choco_features_fact|
      context 'feature exists and is Disabled' do

        before :each do
          facts.merge!(
            {
              :choco_features => choco_features_fact
            }
          )
        end

        it { should contain_chocolatey__config__feature('myfeature').with(
               :feature_name => 'myfeature',
               :enable       => true
        )}
        it { should contain_exec('enable_feature_myfeature')}
        it { should_not contain_exec('disable_feature_myfeature')}

      end # 'and feature exists'
    end

    # Array of possible facts (with stringified facts)
    [
      "{\"myfeature\"=>{\"status\"=>\"Enabled\"}}",
      {
        'myfeature' => {
          'status' => 'Enabled'
        }
      },
    ].each do |choco_features_fact|

      context 'feature exists and is Enabled' do
        before :each do
          facts.merge!(
            {
              :choco_features => choco_features_fact
            }
          )
        end

        it { should contain_chocolatey__config__feature('myfeature').with(
               :feature_name => 'myfeature',
               :enable       => true
        )}
        it { should_not contain_exec('enable_feature_myfeature')}
        it { should_not contain_exec('disable_feature_myfeature')}

      end
    end

    # Array of possible facts (with stringified facts)
    [
      "{\"feature1\"=>{\"status\"=>\"Enabled\"}, \"feature2\"=>{\"status\"=>\"Enabled\"}, \"feature3\"=>{\"status\"=>\"Enabled\"}}",
      {
        'feature1' => {
          'status' => 'Enabled'
        },
        'feature2' => {
          'status' => 'Enabled'
        },
        'feature3' => {
          'status' => 'Enabled'
        },
      },
    ].each do |choco_features_fact|
      context 'feature does not exists' do
        before :each do
          facts.merge!(
            {
              :choco_features => choco_features_fact
            }
          )
        end

        it do
          expect { should compile }.to raise_error(/Feature 'myfeature' is not a valid feature !/)
        end

      end

    end
  end
  context 'when enable is false' do
    before :each do
      params.merge!(
        {
          :enable => false,
        }
      )
    end

    # Array of possible facts (with stringified facts)
    [
      "{\"myfeature\"=>{\"status\"=>\"Enabled\"}}",
      {
        'myfeature' => {
          'status' => 'Enabled'
        }
      },
    ].each do |choco_features_fact|

      context 'feature exists and is Enabled' do
        before :each do
          facts.merge!(
            {
              :choco_features => choco_features_fact
            }
          )
        end

        it { should contain_chocolatey__config__feature('myfeature').with(
               :feature_name => 'myfeature',
               :enable       => false
        )}
        it { should_not contain_exec('enable_feature_myfeature')}
        it { should contain_exec('disable_feature_myfeature')}

      end # 'and feature exists'
    end
  end
  context 'with version < 0.9.9' do
    before :each do
      facts.merge!(
        {
          :chocolateyversion => '0.9.8.31'
        }
      )
    end

    error_message = 'You cannot manage features on choco version < 0.9.9 !'
    it "should fail with message #{error_message}" do
      expect { should compile }.to raise_error(/#{error_message}/)
    end
  end
end
