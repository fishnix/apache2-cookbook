name			 "apache2"
maintainer       "E Camden Fisher"
maintainer_email "fish@fishnix.net"
license          "Apache 2.0"
description      "Installs/Configures apache2"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.3"
%w{ centos redhat amazon scientific }.each do |os|
  supports os
end
