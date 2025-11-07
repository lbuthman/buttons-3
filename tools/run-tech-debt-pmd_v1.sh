#!/usr/bin/env bash
sfdx scanner:run \
  --format json \
  --target "force-app/main/default/classes/$1.cls" \
  --outfile "scans/$1.json" \
  --pmdconfig "scans/level-0-tech-debt-ruleset.xml"

#sfdx scanner:run --format json --target "force-app/main/default/classes/$1.cls" --outfile "scans/$1.json" --pmdconfig "scans/level-0-tech-debt-ruleset.xml"