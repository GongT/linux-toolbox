#!/bin/bash

set +e

ensure_command php
ensure_command expect

echo "#!/bin/bash" > /etc/profile.d/my_script.sh
echo "export MY_SCRIPT_ROOT='${MY_SCRIPT_ROOT}'" >> /etc/profile.d/my_script.sh
echo "source '${MY_SCRIPT_ROOT}/init_my_script'" >> /etc/profile.d/my_script.sh

echo "script installed at ${MY_SCRIPT_ROOT}"
source /etc/profile.d/my_script.sh
