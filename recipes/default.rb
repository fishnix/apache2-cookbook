#
# Cookbook Name:: apache2
# Recipe:: default
#
# Some of below is borrowed from the opscode apache2 cookbook
# but in general I didn't like that they switched from the centos/redhat
# way to the ubuntu way of managing apache
#
# Copyright 2011, E Camden Fisher
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package "apache2" do
  case node[:platform]
    when "centos","redhat","fedora","suse","amazon","scientific"
      package_name "httpd"
    when "debian","ubuntu"
      package_name "apache2"
    when "arch"
      package_name "apache"
    end
  action :install
end

service "apache2" do
  case node[:platform_family]
  when "rhel"
    service_name "httpd"
    # If restarted/reloaded too quickly httpd has a habit of failing.
    # This may happen with multiple recipes notifying apache to restart - like
    # during the initial bootstrap.
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian"
    service_name "apache2"
    restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"
  when "arch"
    service_name "httpd"
  end
  supports value_for_platform(
    "debian" => { "4.0" => [ :restart, :reload ], "default" => [ :restart, :reload, :status ] },
    "ubuntu" => { "default" => [ :restart, :reload, :status ] },
    "centos" => { "default" => [ :restart, :reload, :status ] },
    "redhat" => { "default" => [ :restart, :reload, :status ] },
    "fedora" => { "default" => [ :restart, :reload, :status ] },
    "arch" => { "default" => [ :restart, :reload, :status ] },
    "default" => { "default" => [:restart, :reload ] }
  )
end

# Cleanup some stuff we don't want
%w{ proxy_ajp.conf README welcome.conf }.each do |rm|
  file "#{node[:apache2][:dir]}/conf.d/#{rm}" do
    action :delete
    backup false
  end
end

# Create log dir
directory node[:apache2][:log_dir] do
  mode 0755
  action :create
end

# Create misc config dirs
%w{ ssl conf conf.d }.each do |dir|
  directory "#{node[:apache2][:dir]}/#{dir}" do
    action :create
    mode 0755
    owner "root"
    group "root"
  end
end

template "httpd.conf" do
  case node[:platform_family]
  when "rhel"
    path "#{node[:apache2][:dir]}/conf/httpd.conf"
  when "debian"
    path "#{node[:apache2][:dir]}/apache2.conf"
  end
  source "httpd.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[apache2]"
end

template "modules.conf" do
  path "#{node[:apache2][:dir]}/conf/modules.conf"
  source "modules.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[apache2]"
end

service "apache2" do
  action [:enable, :start]
end
