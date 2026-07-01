#!/bin/bash
set -e
v=1.43.2
# The dev (Haskell toolchain) stage is used only as an internal build stage; we
# no longer tag or push it. Build just the slim production image.
docker image build -t dastapov/hledger:latest -t dastapov/hledger:${v} . "$@"

./run.sh ./data/hledger.journal hledger print || { echo "failed to run container, aborting"; exit 1; }

docker image push dastapov/hledger:${v}
docker image push dastapov/hledger:latest
echo ./update_readme.sh
echo docker pushrm dastapov/hledger
