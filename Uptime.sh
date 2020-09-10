#!/bin/bash

## This will show uptime in number of days
## Use data type integer

### it will grep uptime results for 'day' - if no result for day found, it will output 0
### if day is found it will awk and print third column in uptime results (day)


uptimeRaw=$(uptime)
if [ "$(echo $uptimeRaw | grep day)" ]; then
    uptimeOP=$(echo $uptimeRaw | awk '{print $3}')
else
    uptimeOP=0
fi
echo "<result>$uptimeOP</result>"