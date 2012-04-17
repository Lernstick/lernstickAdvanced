#!/bin/sh

# themes are:
# - solar (sun with super-cool animated eruptions, but slows down boot process significantly!)
# - script (flashy debian logo with simple progress bar, just sucks...)
# - spinfinity (spinning infinity animation and progress bar at bottom, looks nice but shutdown is broken)
# - text (just a simple progress bar at the bottom)

echo "setting solar as default plymouth theme"
/usr/sbin/plymouth-set-default-theme -R text

# see Debian bug #605018
exit 0
