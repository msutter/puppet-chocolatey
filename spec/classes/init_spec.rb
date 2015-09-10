require 'spec_helper'

describe 'chocolatey' do
  let(:facts) {
    {
      :chocolateyversion  => '0.9.9.8',
      :choco_install_path => 'C:\ProgramData\chocolatey',
      :choco_sources      => {},
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
      },
    }
  }

  [{}].each do |params|
    context "#{params}" do
      let(:params) { params }

      it 'should compile successfully' do
        catalogue
      end

      #it { is_expected.to compile }
      #it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('chocolatey') }
      it { is_expected.to contain_class('chocolatey::params') }
      it { is_expected.to contain_class('chocolatey::install') }
      it { is_expected.to contain_class('chocolatey::config') }
    end
  end

  context "chocolatey_download_url =>" do
    ['https://chocolatey.org/api/v2/package/chocolatey/','http://location'].each do |param_value|
      context "#{param_value}" do
        let (:params) {{
          :chocolatey_download_url => param_value
        }}

        it 'should compile successfully' do
          catalogue
        end
      end
    end

    ['\\\\ciflocation\\share','file:///c:/chocolatey.nupkg',false,'bob',3,"4",''].each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let (:params) {{
          :chocolatey_download_url => param_value
        }}

        let(:error_message) { /use a Http\/Https Url that downloads/ }
        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end
  end

  context "choco_install_location =>" do
    ['C:\\ProgramData\\chocolatey','D:\\somewhere'].each do |param_value|
      context "#{param_value}" do
        let (:params) {{
          :choco_install_location => param_value
        }}

        it 'should compile successfully' do
          catalogue
        end
      end
    end

    if Puppet.version < '4.0.0'
      [false].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let (:params) {{
            :choco_install_location => param_value
          }}

          let(:error_message) { /is not a string/ }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end

      #1 is actually a string before v4.
      [1,'https://somewhere','\\\\overhere',''].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let (:params) {{
            :choco_install_location => param_value
          }}

          let(:error_message) { /Please use a full path for choco_install_location/ }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end
    else
      [1,false].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let (:params) {{
            :choco_install_location => param_value
          }}

          let(:error_message) { /is not a string/ }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end

      ['https://somewhere','\\\\overhere',''].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let (:params) {{
            :choco_install_location => param_value
          }}

          let(:error_message) { /Please use a full path for choco_install_location/ }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end
    end
  end

  context "choco_install_timeout_seconds =>" do
    [1500,8000,"1",'30'].each do |param_value|
      context "#{param_value}" do
        let (:params) {{
          :choco_install_timeout_seconds => param_value
        }}

        it 'should compile successfully' do
          catalogue
        end
      end
    end

    ['string',false,''].each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let (:params) {{
          :choco_install_timeout_seconds => param_value
        }}

        let(:error_message) { /Expected first argument to be an Integer/ }
        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end
  end

  ['use_7zip','enable_autouninstaller'].each do |boolean_param|
    context "#{boolean_param} =>" do
      [true, false].each do |param_value|
        context "#{param_value}" do
          let (:params) {{
            boolean_param.to_sym => param_value
          }}

          it 'should compile successfully' do
            catalogue
          end
        end
      end

      ['true','false','bob',3,"4",''].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let (:params) {{
            boolean_param.to_sym => param_value
          }}

          let(:error_message) { /is not a boolean./ }
          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end
    end
  end
end
