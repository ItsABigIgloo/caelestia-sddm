#!/bin/bash
# Simple script to check if the SDDM theme is installed correctly and if there are any issues with SDDM logs or configuration.

echo "=== Checking SDDM Theme Installation ==="
echo "Theme directory exists:"
ls -la /usr/share/sddm/themes/caelestia/ 2>/dev/null && echo "✓ Found" || echo "✗ Missing"
echo -e "\n=== Checking SDDM Config ==="
if grep -rq "^Current=" /etc/sddm.conf /etc/sddm.conf.d/ 2>/dev/null; then
    echo "✓ Found"
else
    echo "✗ Missing"
fi
echo -e "\n=== Checking Required Fonts ==="
fc-list | grep -i "jetbrains mono" && echo "✓ JetBrains Mono" || echo "✗ JetBrains Mono missing"
fc-list | grep -i "material" && echo "✓ Material font" || echo "✗ Material font missing"
echo -e "\n=== Recent SDDM Errors ==="
sudo journalctl -u sddm -b -0 --no-pager | grep -i "error\|warning\|fail" | tail -20