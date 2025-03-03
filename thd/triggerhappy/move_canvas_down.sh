#!/bin/ash
# Read values
i2cset -r -y 1 0x17 0xf0 0x03 b
VRST_VALUE=$(( (($(i2cget -y 1 0x17 0x03) & 0x7f) << 4) + ($(i2cget -y 1 0x17 0x02) >> 4) ))
TOP_VALUE=$(( ( (($(i2cget -y 1 0x17 0x08) & 0x07) << 8) + $(i2cget -y 1 0x17 0x07) +1) ))
BOTTOM_VALUE=$(( ( (($(i2cget -y 1 0x17 0x09) & 0x7f) << 4) + ($(i2cget -y 1 0x17 0x08) >> 4) +1) ))
if [ $BOTTOM_VALUE -eq $VRST_VALUE ]
then
    BOTTOM_VALUE=0
fi
if [ $TOP_VALUE -eq $VRST_VALUE ]
then
    TOP_VALUE=0
fi
# File adjust
MED=$(sed -n '777p' /home/$USER/gbs-control/settings/defaults/current.set)
HIGH=$(sed -n '778p' /home/$USER/gbs-control/settings/defaults/current.set)
LOW=$((TOP_VALUE & 0xff))
MED=$(( ((BOTTOM_VALUE & 0x00F) << 4) + ((TOP_VALUE >> 8) & 0x07) + ($MED & 0x08) ))
HIGH=$(( ((BOTTOM_VALUE >> 4) & 0x7f) + ($HIGH & 0x80) ))
sed -i 776c\\$LOW /home/$USER/gbs-control/settings/defaults/current.set
sed -i 777c\\$MED /home/$USER/gbs-control/settings/defaults/current.set
sed -i 778c\\$HIGH /home/$USER/gbs-control/settings/defaults/current.set
# Register adjust
i2cset -r -y -m 0x07 1 0x17 0x08 $((TOP_VALUE >> 8))
i2cset -r -y -m 0xff 1 0x17 0x07 $((TOP_VALUE & 0xFF))
i2cset -r -y -m 0x7f 1 0x17 0x09 $((BOTTOM_VALUE >> 4))
i2cset -r -y -m 0xf0 1 0x17 0x08 $(( (BOTTOM_VALUE & 0x00F) << 4))
