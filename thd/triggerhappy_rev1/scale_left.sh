#!/bin/ash

# File adjust
LOW=$(sed -n 791p /home/$USER/settings/defaults/current.set)
HIGH=$(sed -n 792p /home/$USER/settings/defaults/current.set)
NEW_VALUE=$(( ( (( $HIGH & 0x03) << 8) + $LOW +1) ))
HIGH=$(( ((NEW_VALUE >> 8) & 0x03) + ($HIGH & 0xfc) ))
LOW=$((NEW_VALUE & 0xff))
sed -i 791c\\$LOW /home/$USER/settings/defaults/current.set
sed -i 792c\\$HIGH /home/$USER/settings/defaults/current.set
# Register adjust
sudo i2cset -r -y 0 0x17 0xf0 0x03 b
NEW_VALUE=$(( ( (($(sudo i2cget -y 0 0x17 0x17) & 0x03) << 8) + $(sudo i2cget -y 0 0x17 0x16) +1) ))
sudo i2cset -r -y -m 0x03 0 0x17 0x17 $((NEW_VALUE >> 8))
sudo i2cset -r -y -m 0xff 0 0x17 0x16 $((NEW_VALUE & 0xff))
