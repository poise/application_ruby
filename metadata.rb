name             "application_ruby"
maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Deploys and configures Ruby-based applications"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.0.2"

%w{ unicorn apache2 passenger_apache2 }.each do |cb|
  depends cb
end

depends "application", "~> 4.0"
depends "runit", "~> 1.0"
depends "logrotate", "~> 1.0"
