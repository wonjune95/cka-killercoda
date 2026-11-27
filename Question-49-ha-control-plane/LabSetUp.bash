#!/bin/bash
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/../lib/common.sh"
bash "$HERE/cleanup.sh"
mkdir -p /root/exercise-49
echo "Lab ready. Write your commands to /root/exercise-49/ha-commands.sh (nothing to run on this cluster)."
