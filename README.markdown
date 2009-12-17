Groups
======
 
This is a CommunityEngine plugin. It's designed to work with the CommunityEngine social networking platform, and won't work unless CE is properly installed.
<<<<<<< HEAD:README.markdown

NOTE: This plugin is in super-alpha-please-be-careful-with-me form. It's very rough, but hopefully will help give people an idea of how to develop CE plugins, and also evolve into a more mature groups functionality for CE.

YOUR HELP IS NEEDED TO IMPROVE THIS PLUGIN! Please fork it, add tests, add documentation, add code, and send me pull requests. Thanks,
Bruno

Installation
------------

1. Install the plugin into your vendor directory: 

      
    script/plugin install git://github.com/bborn/community_engine_groups.git

2. Create and run its migrations:

    script/generate plugin_migration
    rake db:migrate
  
3. Add group routes to your routes.rb file: 

    map.routes_from_plugin :community_engine_groups
  
3. Run tests (more tests needed please!): rake community_engine_groups:test

4. Start your server.

Go to /groups to see what's available. Administrators can create new groups.

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
=======
 
 
How To Build Your CE Plugin
===========================
 
Start building the functionality of your plugin by adding models and controllers in the plugin's app directory. This plugin will be loaded after the rest of CE, so you can override CE models and controllers here.
 
 
Copyright (c) 2009 [name of plugin creator], released under the MIT license
>>>>>>> 7844310784197ac13c8a71aa075278649f545438:README
