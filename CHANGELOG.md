## v1.1.0

* [COOK-2362] - `application_ruby` unicorn uses `run_restart`
* [COOK-2363] - `application_ruby` unicorn should set
  `log_template_name` and `run_template_name`

## v1.0.10:

* [COOK-2260] - pin runit version

## v1.0.8:

* [COOK-2159] - cookbook attribute is not treated as a string

## v1.0.6:

* [COOK-1481] - unicorn provider in application_ruby cookbook should run its restart
  command as root

## v1.0.4:

* [COOK-1572] - allow specification of 'bundle' command via attribute

## v1.0.2:

* [COOK-1360] - fix typo in README
* [COOK-1374] - use runit attribute in unicorn run script
* [COOK-1408] - use user and group from parent resource for runit
  service

## v1.0.0:

* [COOK-1247] - Initial release - relates to COOK-634.
* [COOK-1248] - special cases memcached
* [COOK-1258] - Precompile assets for Rails 3
* [COOK-1297] - Unicorn sub-resource should allow strings for 'port' attribute
