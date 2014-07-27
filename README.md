#Collect

####Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)

##Overview

This module have been created to do exactly what puppetlabs-concat module 
does but in more efficient way. That's it, it constructs files from multiple 
fragments in an ordered way. But doesn't require additional space to save 
fragments temporary and doesn't depend on any other module.

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
