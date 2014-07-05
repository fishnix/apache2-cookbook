require 'spec_helper'

describe 'apache2::default' do
  let (:chef_run) { ChefSpec::Runner.new(platform: 'centos', version: '6.5').converge('apache2::default') }
  
  it 'installs the httpd package' do
    expect(chef_run).to install_package('httpd')
  end
  
  it 'should create the log directory' do
    expect(chef_run).to create_directory('/var/log/httpd')
  end
  
  %w{ ssl conf conf.d }.each do |d|
    it "should create the directory #{d}" do
      expect(chef_run).to create_directory("/etc/httpd/#{d}")
    end
  end
  
  it 'creates httpd config files from template' do
    expect(chef_run).to render_file('/etc/httpd/conf/httpd.conf')
    expect(chef_run).to render_file('/etc/httpd/conf/modules.conf')
  end
  
  it 'restarts apache httpd when /etc/httd/conf/httpd.conf is updated' do
    resource = chef_run.template('/etc/httpd/conf/httpd.conf')
    expect(resource).to notify('service[apache2]').to(:restart)
  end

  it 'restarts apache httpd when /etc/httd/conf/modules.conf is updated' do
    resource = chef_run.template('/etc/httpd/conf/modules.conf')
    expect(resource).to notify('service[apache2]').to(:restart)
  end 
end