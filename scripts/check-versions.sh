#!/usr/bin/env bash
#
# check-versions.sh — do the plugin's version strings agree?
#
# The plugin's version is written in four places. They have to match, and nothing
# was checking. Run this before tagging a release.
#
#   ./scripts/check-versions.sh          # check
#   ./scripts/check-versions.sh --tag    # also check the newest git tag agrees
#
# Exits 0 when everything agrees, 1 when it doesn't.
#
# NOT checked: skills/plan/SKILL.md. The plan skill versions independently — it is
# its own skill with its own release cadence, currently 1.3.0 against the plugin's
# 3.0.3. Requiring those to match would be wrong, not stricter.
#
# Added 2026-08-27, after a review found four version strings with nothing keeping
# them honest. The same drift had already produced two real defects that week: a
# README claiming a version its own manifest disagreed with, and a shared file that
# silently stopped tracking its upstream.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

fail=0
report() { printf '  %-34s %s\n' "$1" "$2"; }

read_json_version() {  # file, jq-ish path via python
  python3 -c "
import json, io, sys
try:
    d = json.load(io.open('$1'))
    v = $2
    print(v if v else 'MISSING')
except FileNotFoundError:
    print('NO-FILE')
except Exception as e:
    print('UNREADABLE')
" 2>/dev/null
}

PLUGIN=$(read_json_version ".claude-plugin/plugin.json" "d.get('version')")
MARKET=$(read_json_version ".claude-plugin/marketplace.json" "d.get('plugins',[{}])[0].get('version')")
SKILL=$(grep -m1 '^version:' skills/workflow-audit/SKILL.md 2>/dev/null | awk '{print $2}')
SKILL=${SKILL:-MISSING}
CHANGELOG=$(grep -m1 -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' CHANGELOG.md 2>/dev/null | tr -d 'v')
CHANGELOG=${CHANGELOG:-MISSING}

echo "Version strings:"
report ".claude-plugin/plugin.json"      "$PLUGIN"
report ".claude-plugin/marketplace.json" "$MARKET"
report "skills/workflow-audit/SKILL.md"  "$SKILL"
report "CHANGELOG.md (newest entry)"     "$CHANGELOG"

for v in "$PLUGIN" "$MARKET" "$SKILL" "$CHANGELOG"; do
    case "$v" in
        MISSING|NO-FILE|UNREADABLE) fail=1 ;;
        "$PLUGIN") ;;
        *) fail=1 ;;
    esac
done

if [ "$fail" -eq 0 ]; then
    echo "✅ all agree on $PLUGIN"
else
    echo "❌ they disagree — fix before tagging"
fi

# The git tag is only meaningful once a release exists, so it is opt-in.
if [ "${1:-}" = "--tag" ]; then
    TAG=$(git tag --sort=-v:refname 2>/dev/null | head -1)
    echo
    report "newest git tag" "${TAG:-none}"
    if [ -n "$TAG" ] && [ "${TAG#v}" != "$PLUGIN" ]; then
        echo "⚠️  newest tag is ${TAG}, manifests say ${PLUGIN}"
        echo "   Fine mid-cycle (you have not tagged this release yet)."
        echo "   Wrong if you meant to tag ${PLUGIN} already."
    fi
fi

echo
echo "Not checked: skills/plan/SKILL.md ($(grep -m1 '^version:' skills/plan/SKILL.md 2>/dev/null | awk '{print $2}')) — versions independently, by design."

exit "$fail"
