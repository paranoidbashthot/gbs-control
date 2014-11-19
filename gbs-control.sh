#!/bin/bash
# GBS82000 & GBS8220 Control over I2C bash script
# Version 0.1
# Code structure & Interactive shell script from raspi-config
#

INTERACTIVE=True

#
calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error 
  # output from tput. However in this case, tput detects neither stdout or 
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=17
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-8))
}


folder_scripts () {
  cd scripts
}


#
#
do_set_Vds_hb_st() {
  LOW=$(sed -n 773p settings/defaults/current.set)
  HIGH=$(sed -n 774p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x0f) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hblank Start (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x0f) + ($HIGH & 0xf0) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 773c\\$LOW settings/defaults/current.set
	sed -i 774c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_hb_sp() {
  LOW=$(sed -n '774p' settings/defaults/current.set)
  HIGH=$(sed -n '775p' settings/defaults/current.set)
  CURRENT_VALUE=$(( ($HIGH << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hblank Stop (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( NEW_VALUE >> 4 ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 774c\\$LOW settings/defaults/current.set
	sed -i 775c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_vb_st() {
  LOW=$(sed -n 776p settings/defaults/current.set)
  HIGH=$(sed -n 777p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x07) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vblank Start (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x07) + ($HIGH & 0xf8) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 776c\\$LOW settings/defaults/current.set
	sed -i 777c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_vb_sp() {
  LOW=$(sed -n '777p' settings/defaults/current.set)
  HIGH=$(sed -n '778p' settings/defaults/current.set)
  CURRENT_VALUE=$(( (($HIGH & 0x7f) << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vblank Stop (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 4) & 0x7f) + ($HIGH & 0x80) ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 777c\\$LOW settings/defaults/current.set
	sed -i 778c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_hs_st() {
  LOW=$(sed -n 779p settings/defaults/current.set)
  HIGH=$(sed -n 780p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x0f) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hsync Start (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x0f) + ($HIGH & 0xf0) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 779c\\$LOW settings/defaults/current.set
	sed -i 780c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_hs_sp() {
  LOW=$(sed -n '780p' settings/defaults/current.set)
  HIGH=$(sed -n '781p' settings/defaults/current.set)
  CURRENT_VALUE=$(( ($HIGH << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hsync Stop (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( NEW_VALUE >> 4 ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 780c\\$LOW settings/defaults/current.set
	sed -i 781c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_vs_st() {
  LOW=$(sed -n 782p settings/defaults/current.set)
  HIGH=$(sed -n 783p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x07) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vsync Start (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x07) + ($HIGH & 0xf8) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 782c\\$LOW settings/defaults/current.set
	sed -i 783c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_vs_sp() {
  LOW=$(sed -n '783p' settings/defaults/current.set)
  HIGH=$(sed -n '784p' settings/defaults/current.set)
  CURRENT_VALUE=$(( (($HIGH & 0x7f) << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vsync Stop (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 4) & 0x7f) + ($HIGH & 0x80) ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 783c\\$LOW settings/defaults/current.set
	sed -i 784c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_dis_hb_st() {
  LOW=$(sed -n 785p settings/defaults/current.set)
  HIGH=$(sed -n 786p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x0f) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hblank Start (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x0f) + ($HIGH & 0xf0) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 785c\\$LOW settings/defaults/current.set
	sed -i 786c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_dis_hb_sp() {
  LOW=$(sed -n '786p' settings/defaults/current.set)
  HIGH=$(sed -n '787p' settings/defaults/current.set)
  CURRENT_VALUE=$(( ($HIGH << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Hblank Stop (0 - 4095)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( NEW_VALUE >> 4 ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 786c\\$LOW settings/defaults/current.set
	sed -i 787c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_dis_vb_st() {
  LOW=$(sed -n 788p settings/defaults/current.set)
  HIGH=$(sed -n 789p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x07) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vblank Start (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x07) + ($HIGH & 0xf8) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 788c\\$LOW settings/defaults/current.set
	sed -i 789c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_dis_vb_sp() {
  LOW=$(sed -n '789p' settings/defaults/current.set)
  HIGH=$(sed -n '790p' settings/defaults/current.set)
  CURRENT_VALUE=$(( (($HIGH & 0x7f) << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Vblank Stop (0 - 2047)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 4) & 0x7f) + ($HIGH & 0x80) ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 789c\\$LOW settings/defaults/current.set
	sed -i 790c\\$HIGH settings/defaults/current.set
  fi
}


do_output_geometry_menu() {
while true; do
  FUN=$(whiptail --title "Rasberry Pi GB8200 / GBS8220 Controller" --menu "Output Geometry" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "1.1 Set Vds_hb_st" "Set Horizontal Left Offset" \
	"1.2 Set Vds_hb_sp" "Set Horizontal Width" \
	"1.3 Set Vds_vb_st" "Set Vertical Top Offset" \
	"1.4 Set Vds_vb_sp" "Set Vertical Length" \
    "1.5 Set Vds_hs_st" "Set Horizontal sync start position" \
	"1.6 Set Vds_hs_sp" "Set Horizontal sync stop position " \
	"1.7 Set Vds_vs_st" "Set Vertical sync start position" \
	"1.8 Set Vds_vs_sp" "Set Vertical sync stop position" \
	"1.9 Set Vds_dis_hb_st" "Set Horizontal blanking start position" \
	"1.10 Set Vds_dis_hb_sp" "Set Horizontal blanking stop position" \
	"1.11 Set Vds_dis_vb_st" "Set Vertical blanking start position" \
	"1.12 Set Vds_dis_vb_sp" "Set Vertical blanking stop position" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1.1\ *) do_set_Vds_hb_st ;;
	  1.2\ *) do_set_Vds_hb_sp ;;
	  1.3\ *) do_set_Vds_vb_st ;;
	  1.4\ *) do_set_Vds_vb_sp ;;
	  1.5\ *) do_set_Vds_hs_st ;;
	  1.6\ *) do_set_Vds_hs_sp ;;
	  1.7\ *) do_set_Vds_vs_st ;;
	  1.8\ *) do_set_Vds_vs_sp ;;
	  1.9\ *) do_set_Vds_dis_hb_st ;;
	  1.10\ *) do_set_Vds_dis_hb_sp ;;
	  1.11\ *) do_set_Vds_dis_vb_st ;;
	  1.12\ *) do_set_Vds_dis_vb_sp ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
done
}

#
#
do_set_Sp_pre_coast() {
  CURRENT_VALUE=$(( $(sed -n '1337p' settings/defaults/current.set) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Coast Start (0 - 255)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    sed -i 1337c\\$NEW_VALUE settings/defaults/current.set
  fi
}

do_set_Sp_post_coast() {
  CURRENT_VALUE=$(( $(sed -n '1338p' settings/defaults/current.set) ))
  NEW_VALUE=$(whiptail --inputbox "Enter Coast Stop (0 - 255)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    sed -i 1338c\\$NEW_VALUE settings/defaults/current.set
  fi
}

do_input_capture_menu() {
while true; do
  FUN=$(whiptail --title "Rasberry Pi GB8200 / GBS8220 Controller" --menu "Input Sync Capture" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
	"2.1 Set Sp_pre_coast" "Set the coast start point before vertical sync line number" \
	"2.2 Set Sp_post_coast" "Set when coast will disable (return to normal PLL function)" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      2.1\ *) do_set_Sp_pre_coast ;;
	  2.2\ *) do_set_Sp_post_coast ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
done
}

#
#
do_set_Vds_vscale() {
  LOW=$(sed -n '792p' settings/defaults/current.set)
  HIGH=$(sed -n '793p' settings/defaults/current.set)
  CURRENT_VALUE=$(( (($HIGH & 0x7f) << 4) + ($LOW >> 4) ))
  NEW_VALUE=$(whiptail --inputbox "Enter V Scalling (0 - 1023)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 4) & 0x7f) + ($HIGH & 0x80) ))
	LOW=$(( ((NEW_VALUE << 4) & 0xf0) + ($LOW & 0x0f) ))
    sed -i 792c\\$LOW settings/defaults/current.set
	sed -i 793c\\$HIGH settings/defaults/current.set
  fi
}

do_set_Vds_hscale() {
  LOW=$(sed -n 791p settings/defaults/current.set)
  HIGH=$(sed -n 792p settings/defaults/current.set)
  CURRENT_VALUE=$(( (( $HIGH & 0x03) << 8) + $LOW ))
  NEW_VALUE=$(whiptail --inputbox "Enter H Scalling (0 - 1023)" 20 60 "$CURRENT_VALUE" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    HIGH=$(( ((NEW_VALUE >> 8) & 0x03) + ($HIGH & 0xfc) ))
	LOW=$((NEW_VALUE & 0xff))
    sed -i 791c\\$LOW settings/defaults/current.set
	sed -i 792c\\$HIGH settings/defaults/current.set
  fi
}

do_hv_scalling_menu() {
while true; do
  FUN=$(whiptail --title "Rasberry Pi GB8200 / GBS8220 Controller" --menu "H/V Scalling" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
	"3.1 Set Vds_hscale" "Set horizontal scalling" \
	"3.2 Set Vds_vscale" "Set vertical scalling" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      3.1\ *) do_set_Vds_hscale ;;
	  3.2\ *) do_set_Vds_vscale ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
done
}


do_save() {

  NEW_VALUE=$(whiptail --inputbox "Enter Setting Name" 20 60 "default" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    sudo cp -f settings/defaults/current.set "settings/"$NEW_VALUE".set" >> log.txt 2>&1
  fi
}

folder_settings () {
  cd settings
}

do_load() {
  # Set the prompt for the select command
  PS3="Type a number or 'q' to quit: "
   
  # Create a list of files to display
  folder_settings
  fileList=$(find ./ -maxdepth 1 -type f | sort)
  cd ..
   
  # Show a menu and ask for input. If the user entered a valid choice,
  # then copy file to current settings cache
  select fileName in $fileList; do
  if [ -n "$fileName" ]; then
    sudo cp -f settings/$fileName settings/defaults/current.set >> log.txt 2>&1
  fi
  break
done
}



do_finish() {
  exit 0
}

# Everything needs to be run as root
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo bash gbs-config.sh'\n"
  exit 1
fi

#
# Interactive use loop
#
#sudo python scripts/rawProg.py scripts/start.txt > log.txt 2>&1
calc_wt_size
while true; do
  FUN=$(whiptail --title "Rasberry Pi GB8200 / GBS8220 Controller" --menu "Setup Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
	"1 Geometry" "Shift output image and blanking" \
	"2 Coast" "Input sync & sampling settings" \
	"3 H/V Scalling" "Change output canvas scalling" \
	"4 Save Settings" "Save current settings to file" \
	"5 Load Settings" "Load previous settings from file"\
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
	  1\ *) do_output_geometry_menu ;;
	  2\ *) do_input_capture_menu ;;
	  3\ *) do_hv_scalling_menu ;;
	  4\ *) do_save ;;
	  5\ *) do_load ;;
      *) whiptail --msgbox "Programmer error: unrecognised option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done
