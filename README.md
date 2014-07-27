#Collect

####Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
3. [Todo](#todo)

##Overview

This module have been created to do exactly what puppetlabs-concat module 
does but in more efficient way. That's it, it constructs files from multiple 
fragments in an ordered way. But doesn't require additional space to save 
fragments temporary and doesn't depend on any other module.

The main problem I had when using puppetlabs-concat module was the execution 
time. When I generated 1500 files, every file from 4 or 5 fragments, it takes
more then 50 minutes for the catalog to be executed in the agent. So I read
the puppetlabs-concat code I said that it creates one file for every fragment 
and updates the final file every time a fragment is added. Isn't there any more
simple way to do it ?

My first try was using some global variable which will hold all fragments and 
create files only at the end. But it didn't work because puppet doesn't allow
changing the values of variables in other scope ! So I finally ended by just
declaring resources and then collect them using a template. And it just works 
fine and finish execution more quickly.

##Usage

If you wanted a /etc/motd file that listed all the major modules
on the machine.  And that would be maintained automatically even
if you just remove the include lines for other modules you could
use code like below, a sample /etc/motd would be:

<pre>
Puppet modules on this server:

    -- Apache
    -- MySQL
</pre>

Local sysadmins can also append to the file by just editing /etc/motd.local
their changes will be incorporated into the puppet managed motd.

```puppet
class motd {
  include collect
  $motd = '/etc/motd'

  collect::file { $motd:
    path => $motd
  }

  collect::part{ 'motd_header':
    target  => $motd,
    content => "\nPuppet modules on this server:\n\n",
    order   => 1
  }

  # local users on the machine can append to motd by just creating
  # /etc/motd.local
  collect::part{ 'motd_local':
    target => $motd,
    source => '/etc/motd.local',
    order  => 15
  }
}

# used by other modules to register themselves in the motd
define motd::register($content="", $order=10) {
  if $content == "" {
    $body = $name
  } else {
    $body = $content
  }

  collect::part{ "motd_fragment_$name":
    target  => '/etc/motd',
    order   => $order,
    content => "    -- $body\n"
  }
}
```

To use this you'd then do something like:

```puppet
class apache {
  include apache::install, apache::config, apache::service

  motd::register{ 'Apache': }
}
```
##Todo

add missing arguments to collect::file ressource trying to make it just like file ressource 
 