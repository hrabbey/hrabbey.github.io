#!/bin/sh
#
# changeSwap.sh -  program to change swap space
#   version 0.1.2, last modified 6/4/02
#
# Copyright (C) 2002 hrabbey@surfbest.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
###
# For current version and info, see:
#  http://members.surfbest.net/hrabbey@surfbest.net/Projects/ChangeSwap/
# or perhaps:  http://hrabbey.webhop.net/Projects/ChangeSwap/
#
# bug fixes and improvment patches desired.
# donations  accepted (preferably in the form of job leads, 
#  encouraging e-mails, or post cards).
######################################################################
###Bug List:
# report of not uninstalling incorrectly by Watchmaster.
# NEED appropriately cool & obvious icon
# icon text should be "Adj. Storage vs. Mem." not "Adjust Disk vs. Mem."
# occasionally icon gets put on taskbar.  Seems to happen when ran quickly 
#  twice in a row. Causes problems by always restarting. Don't know cause. 
#  Workaround: when happens, restart Qtopia.
# beautify indents,  
# make sure syntax compatible with ash, esp. since bash (which I'm used to) 
#  isn't accepted by Qt Launcher.  Where are docs on Zaurus's ash??
# subroutine error exit and return values correctly done?
# pass option to subroutines: swapsize & EXITCODE
# check -c ### option passed is a number
# reformat -h help so readable on all 3 terminal fonts, incl. stripping off dir.
# separate configuration from program : source ~/Settings/swapChange.conf or /etc/swapChange.conf
# if default cnfig, don't mention swap file names.  Use terms appropriate for complete newbie.
###Desired feature list:
# auto detect partition swapfile is on: see SWAPPART config option notes
# if possible, default action should depend if called from terminal (print 
#  usage to terminal) or direct from Qt.
# handle long options, esp. --help ( getopts (sh builtin) can't handle 
#  long opts. )
# Perhaps use list dialog box instead of dialog, and give range of size options.
# add option to reduce swap space & file
# adjust for previous files: can add number to ending to add files.
# add location as option: in(ternal), cf, sd 
# restrict cf and sd usage to -a(dvanced) option usage
# add -q(uiet) & -v(erbose) options
# Internationalization / configurable messages
# add init script to turn available swap on upon boot.
#
# make nicer looking gui via rewriting in C 
# can do external cmds in C: popen, etc.
# C requres no extra libs, and plentiful  examples
## Desired gui control and options:
## page showing current info, and controls for current options; 
##  once completely adjustable, make slider tab, w/ ok/do it / update button.
#
## gui extras
## leave sysinfo interaction to Opie folks / MevWorld:
##  add swap space on storage tab of sysinfo; hold to start swap config
## combine / be called from mevworld's sysinfo swapinfo tab
##  use mevworlds mem. tab to show swap.; total swap hold to start swap config;
##  if no swap, hide swap info; ?on total mem, hold to start swap config
#
# Report /Fix bugs (disk free check et al.) in swapd so can suggest it as 
#  well.  Change to work with it.
#
# other ideas?
#
######################################################################
# Configuration options
#
#SWAPFILE=/home/root/swapfile
#SWAPFILE=/home/swapfile
#SWAPFILE=/home/swap.file
#CF:
#SWAPFILE=/mnt/cf/SwapFile
SWAPFILE=/mnt/cf/Temp/swapFile
#SWAPFILE=/mnt/cf/pose/.swap
#
#Partition SWAPFILE is on
# used to get df info, since df /directory/ not reliable.
# should be able to find automatically w/ df or mount or chase, or ?...
# should / could be in(ternal), cf or sd
#internal:
#SWAPPART=/dev/mtdblock1
#CF:
SWAPPART=/dev/hda1
#
#Minimum to be kept free in k
#MINFREE=300
MINFREE=900
#
OPIE_SH=/opt/QtPalmtop/bin/opie-sh
#
#Can save 4k or so by removing comments:
#   [ not that I think it would ever be worth it...]
#  cat changeSwap.sh | grep -v "^#" > changeSwap.trimmed.sh
#  echo '#!/bin/sh' > changeSwap.sh
#  cat  changeSwap.trimmed.sh >>  changeSwap.sh
#  rm changeSwap.trimmed.sh 
#
## end config
#
######################################################################
# subroutines

print_usage() 
{
    echo  "  Usage:
$0 -c nnn | -d | -m | -t | -g | -h 
  -c  create swap space file of nnn kilobytes
  -d  delete swap
  -m create swap with almost all space
  -t toggle between -m and -d
  -h this help message
   -g use Qt "gui" interface
       without an option, brings up Qt 
       "gui" interface, if available
"


}

# Find amount of free space
DISKFREE=`df | grep $SWAPPART | tr -s ' ' | cut -f 4 -d ' '  `

# Create swap subroutine
make_swap ( )
{
  # does file already exist?
if [ -e $SWAPFILE ] 
  then
   echo swap file $SWAPFILE already exists!
   echo No action taken.
   EXITCODE=1
   close_program
   exit 99
fi

if  [ $SWAPSIZE -lt 40 ] 
  then
    echo Error: size must be at least 40
    echo No action taken
    EXITCODE=2
    close_program
    exit 99
fi
	
#check if requested size will fit on storage disk
if [ $(( $SWAPSIZE + $MINFREE )) -gt $DISKFREE ]
   then
    echo Error: not enough space for a $SWAPSIZE k file!
    echo No action taken
    EXITCODE=3
    close_program
    exit 99
fi
	
echo making swap file of $SWAPSIZE k
dd if=/dev/zero of=$SWAPFILE  bs=1k count=$SWAPSIZE
mkswap $SWAPFILE
swapon $SWAPFILE

}

#Remove swap subroutine
del_swap ()
{
      if [ ! -e $SWAPFILE ] 
         then
           echo swap file $SWAPFILE does not exist.
           echo No action taken.
           EXITCODE=1
           close_program
           exit 99
     fi

     echo removing swap space file $SWAPFILE
     swapoff $SWAPFILE
     rm $SWAPFILE
}

# Do nothing to make qt_iface output somewhat more sensible
nothing ()
{
  #no op
}

# Opie-sh dialogs
qt_iface ()
{
# Usage Hint for old ver. 0.1 of opie-sh:
#  To do nothing, tap x, press cancel or pick the left button.
#  To do the indicated action. tap OK, press OK, or pick the right button. 
#  The action toggles the free disk storage space between mostly swap file 
#  and no swap file. "
# With current (0.4) / all ver of opie-sh, Ok & esc keys & corner icons react differently.   howto says error code is -1 for both now.  

# From tips; doesn't seem usefull w/ opie-sh ver. 0.1, but good in ver 0.4
# add "Working..." screen between dialog & report
echo "<h1>changeSwap</h1>
Adjusts between available memory and free storage space.
Run changeSwap.sh -h to list all options
   " | $OPIE_SH -t changeSwap.sh -f  &
WORKINGSCREEN=$!

# if swap exists, ask to remove
if [ -e $SWAPFILE ] 
 then
        $OPIE_SH -m -t "Change Swap" -M "Remove swap file?" -w -0 "Cancel" -1 "Remove" 
        RETURNCODE=$?
        case $RETURNCODE in
                -1)  # opie-sh ver. 0.2 returns -1 for OK and x corner icons
                        #  maybe also: unexpected input detected; no action taken
                        ACTION=nothing
                     ;;
                0)   ACTION=nothing ;;
                1)  ACTION=del_swap ;;
        esac
else
        # if doesn't exist, ask to have max.
        $OPIE_SH -m -t "Change Swap" -M " Make large swap file?" -w -0 "Cancel"  -1 "Make swap"
        RETURNCODE=$? 
        case $RETURNCODE in
               -1)  # opie-sh ver. 0.2 returns -1 for OK and x corner icons
                       #  maybe also: unexpected input detected; no action taken
                       ACTION=nothing
                     ;;
                0)   ACTION=nothing ;;
                1)  ACTION=make_swap ;;
        esac                                          

            # create Max swap file
            SWAPSIZE=$(( $DISKFREE - $MINFREE ))
            # echo nearly filling storage with $SWAPSIZE k swap space
            # del_swap or make_swap done on show results screen
fi


# show results, current swap & free space
( echo "<h3>Output of $ACTION
:</h3><pre>"
  $ACTION  2>&1
  echo "</pre>"  
  echo "<hr>"
  echo "<h3>Total swapspace:" `free | grep Swap | tr -s ' ' | cut -f 3 -d ' '  ` " k </h3>"
  echo "<h3>Free storage space: " `df -k | grep $SWAPPART | tr -s ' ' | cut -f 4 -d ' '  ` " k </h3>"
  echo done.
  echo "<hr>"
  echo "<h1>changeSwap</h1>"
  echo "Adjusts between available memory and free storage space.
        Run changeSwap.sh -h to list all options"
  kill $WORKINGSCREEN

) | $OPIE_SH -f 
#
# default is max/min to toggle current state.
# could I do a slider slider via dialogs?
}


# Close program:
# implement close() 
close_program ()
{
  rm /tmp/qcop-msg-changeSwap.sh
  # any other clean up?
  #exits w/ errorcode.
  exit $EXITCODE   
}

##
######################################################################
# main
#
# Default exit error code:
EXITCODE=0
#####
# check for sensible options
#
getopts htc:dmg OPT 
## help, toggle, create nnn, delete, max
#
# Check for double options
#  should be a better way:
getopts htc:dmg SCDOPT
if [ ! $SCDOPT = ? ]
   then 
       echo multiple options not yet allowed, 
       echo No action taken.
       print_usage
       EXITCODE=1
       close_program
       exit 99
fi

#check for existance of opie-sh
if [ ! -x $OPIE_SH ]
   then
      OPIE_SH=/bin/false
      echo opie-sh not found.
fi

# Act based on given option
case  $OPT in
  h) # Print help
      print_usage
      close_program
       ;;
  t) # Toggle swap space
      if [ -e $SWAPFILE ] 
         then
            del_swap
      else
            # create Max swap file
            SWAPSIZE=$(( $DISKFREE - $MINFREE ))
            echo nearly filling storage with $SWAPSIZE k swap space
            # should be able to drop through, but how?
            make_swap
      fi
      close_program
       ;;
  d) # Want swap removed
       del_swap
       close_program
       ;;
  m) # create Max swap file
      SWAPSIZE=$(( $DISKFREE - $MINFREE ))
      echo nearly filling storage with $SWAPSIZE k swap space
      # should be able to drop through, but how?
      make_swap
      close_program
      ;;
  c) ## Adding swapfile:

      # should check OPTARG  is a number
      SWAPSIZE=$OPTARG
      make_swap
      echo Total swapspace: `free | grep Swap | tr -s ' ' | cut -f 3 -d ' '  `
      echo Free storage space:  `df -k | grep $SWAPPART | tr -s ' ' | cut -f 4 -d ' '  `
      close_program
      ;;
   g) # GUI interface
        qt_iface
        close_program
      ;;
   *)  #Default
        #BUG# Desired default if terminal: 
        #          help and print current swap
        #
        # if Qt interface available, use it:
        if [  $OPIE_SH != /bin/false ]
            then
              qt_iface
              close_program
        else
              #print help and print current swap
              print_usage
              echo  Current swap:
              free | grep Swap
              EXITCODE=99
              close_program
        fi
       ;;
esac

echo Error: unknown state
exit 98
#####
