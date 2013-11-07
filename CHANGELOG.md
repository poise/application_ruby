application_ruby Cookbook CHANGELOG
===================================
This file is used to list changes made in each version of the application_rubycookbook.


v3.0.2
------
No changes, bumping version to get bits in various places in sync.


v3.0.0
------
Major version bump. Breaking backwards compatibility with Chef10.x


v2.2.0
------
### Bug
- **[COOK-3895](https://tickets.opscode.com/browse/COOK-3895)** - application_ruby use_omnibus_ruby attr needs to default to false
- **[COOK-3894](https://tickets.opscode.com/browse/COOK-3894)** - application_ruby cookbook needs version bump to pick up application v4.0 cookbook
- **[COOK-2079](https://tickets.opscode.com/browse/COOK-2079)** - Attempting to touch restart.txt should not cause a chef-client run to fail.


v2.1.4
------
### Bug
- **[COOK-3625](https://tickets.opscode.com/browse/COOK-3625)** - Fix an issue where unicorn fails when node does not provide cpu count


v2.1.2
------
### Improvement
- **[COOK-3616](https://tickets.opscode.com/browse/COOK-3616)** - Simplify log symlinking for rails apps

v2.1.0
------
### Improvement
- **[COOK-3367](https://tickets.opscode.com/browse/COOK-3367)** - Support more of unicorn's configuration
- **[COOK-3124](https://tickets.opscode.com/browse/COOK-3124)** - Add `memcached_template` attribute to so alternative templates may be used

v2.0.0
------
### Bug

- [COOK-3306]: Multiple Memory Leaks in Application Cookbook
- [COOK-3219]: `application_ruby` cookbook bundle install in 1.9.3-based omnibus installs 1.9.x gems into ruby 2.0 apps

v1.1.4
------
### Sub-task

- [COOK-2806]: Including `passenger_apache2::mod_rails` does not enable passenger

v1.1.2
------
### Bug

- [COOK-2638]: cookbook attribute is not treated as a string when specifying `database_yml_template`

### Improvement

- [COOK-2525]: application_ruby: split runit template into multiple lines

v1.1.0
------
- [COOK-2362] - `application_ruby` unicorn uses `run_restart`
- [COOK-2363] - `application_ruby` unicorn should set `log_template_name` and `run_template_name`

v1.0.10
-------
- [COOK-2260] - pin runit version

v1.0.8
------
- [COOK-2159] - cookbook attribute is not treated as a string

v1.0.6
------
- [COOK-1481] - unicorn provider in application_ruby cookbook should run its restart command as root

v1.0.4
------
- [COOK-1572] - allow specification of 'bundle' command via attribute

v1.0.2
------
- [COOK-1360] - fix typo in README
- [COOK-1374] - use runit attribute in unicorn run script
- [COOK-1408] - use user and group from parent resource for runit service

v1.0.0
------
- [COOK-1247] - Initial release - relates to COOK-634.
- [COOK-1248] - special cases memcached
- [COOK-1258] - Precompile assets for Rails 3
- [COOK-1297] - Unicorn sub-resource should allow strings for 'port' attribute
