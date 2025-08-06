#!/usr/bin/bash

exec unshare --fork --mount-proc --mount \
  /usr/bin/bash --login -c "mount -t tmpfs tmpfs /tmp && cd /tmp && printf '\ecRunning BASH in private /tmp\n' && exec /usr/bin/bash"
