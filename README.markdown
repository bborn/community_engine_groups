Groups [v.9.0]
==============
 
NOTE: This plugin is in super-alpha-please-be-careful-with-me form. It's very rough, but hopefully will help give people an idea of how to develop CE plugins, and also evolve into a more mature groups functionality for CE.

YOUR HELP IS NEEDED TO IMPROVE THIS PLUGIN! Please fork it, add tests, add documentation, add code, and send me pull requests. Thanks,
Bruno

Installation
------------

1. Install the plugin into your vendor directory: 

        script/plugin install git://github.com/bborn/community_engine_groups.git

2.  Run the install template:

        rake rails:template LOCATION=vendor/plugins/community_engine_groups/install_template.rb    
  
3. Run tests (more tests needed please!): `rake community_engine_groups:test`

4. Start your server.

Go to `/groups` to see what's available. Administrators can create new groups.


Requirements
------------
- formtastic gem [http://gemcutter.org/gems/formtastic](http://gemcutter.org/gems/formtastic)
- resource_controller plugin [http://github.com/jamesgolick/resource_controller](http://github.com/jamesgolick/resource_controller)


THANKS
------

Special thanks to LeviRosol, who contributed the bulk of this initial codebase.

 
TO DO
-----
  - test coverage (lots of it)  
  - general refactoring (lots of stuff left over from copying from User object)  
  - track activities (group created, group joined)
  - make membership approval optional 
  - add group descriptions


  
  
Copyright (c) 2009 Bruno Bornsztein, released under the MIT license