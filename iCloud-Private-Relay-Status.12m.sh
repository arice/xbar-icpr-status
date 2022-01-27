#!/bin/bash

# <xbar.title>iCloud Private Relay Status</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Ask Adam</xbar.author>
# <xbar.author.github>arice</xbar.author.github>
# <xbar.desc>This plugin will  indicate whether iCloud Private Relay is active by comparing your WAN IP to Apple's list of iCloud Private Relay egress servers.</xbar.desc>
# <xbar.image>https://askadam.io/imgs/xbar-icpr-image.png</xbar.image>
# <xbar.dependencies>curl</xbar.dependencies>

if [ $(curl -LI http://google.com -o /dev/null -w '%{http_code}\n' -s) == "200" ]; then
# we have an internet connection
    wanIP=$(curl -s https://ipinfo.io/ip)
    iCloudPrivateRelayIP=$(CURL -s http://ifconfig.me)
    # using http and ifconfig.me seems to reliably return the iCloud Private Relay IP if Private Relay is enabled

    # build the strings to use for the menu output
    wanresult_string="Public IP: $wanIP | bash='/bin/bash' param1='-c' param2='/bin/echo $wanIP | pbcopy' terminal=false"
    icprresult_string="iCloud Relay IP: $iCloudPrivateRelayIP | bash='/bin/bash' param1='-c' param2='/bin/echo $iCloudPrivateRelayIP | pbcopy' terminal=false"


    # now, get the public list of iCloud Private Relay egresses
    # HEY! need to figure out a way to grab this daily instead of each update, because
    # the file is about 9 MB

    rm /tmp/io.askadam.egress-ip-ranges*.csv # don't fill up your storage with these!

    timestamp=$(date +%s)
    egresses="io.askadam.egress-ip-ranges-$timestamp.csv"
    curl --location --silent "https://mask-api.icloud.com/egress-ip-ranges.csv" -o "/tmp/$egresses"    
    iCloudEgressList="/tmp/$egresses"
    
    # test if our potential relay IP shows up in the list we just got from Apple
    ICPResult_in_EgressList=$(grep "$iCloudPrivateRelayIP" "$iCloudEgressList")
    
    
    # here, we set the menu bar icon to either a green sparkle (yay safe!) or a red flag (boo danger!)
    if [ "$wanIP" != "$iCloudPrivateRelayIP" ] && [ ICPResult_in_EgressList != "" ]; then
        ICP_active=true
        echo "❇️️"
    else
        ICP_active=""
        echo "🚩"
    fi
else
    wanresult_string="No Internet Connection"
    echo "❌️"
fi

d=$(date +"%A, %b %d, %I:%M %p")

echo '---' 

# operational code; commented out for screenshot
echo "$wanresult_string"
if [ "$ICP_active" = true ]; then
    echo "$icprresult_string"
fi

# menu items for screenshot
# echo "Public IP: 25.0.0.7"
# echo "iCloud Relay IP: 172.224.224.7"

echo "Checked: $d"

echo ---
echo "Refresh... | refresh=true"
