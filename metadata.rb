name             "application_ruby"
maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Deploys and configures Ruby-based applications"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "1.1.0"

%w{ application unicorn apache2 passenger_apache2 }.each do |cb|
  depends cb
end

depends "runit", "~> 1.0"
