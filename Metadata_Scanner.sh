#!/bin/bash
# ================================================================================================================================================
# Course:
#   Cyber Security, May, 2020
# Project Name:
#   #2 - Metadata.
# Objective:
#   Create a code that scans pictures from URLs of a database and finds if there is hidden data and GPS coordinates.
# Student Name:
#   Robert Jonny Tiger.
# ================================================================================================================================================
# Credits:
#   Nipe: GouveaHeitor @ GitHub
# ================================================================================================================================================

# Basic variables:
echo "Loading... Please hold."
DIRPATH=$(find / -type d -name "Project_Metadata" 2>/dev/null) # Sets the location of the script's directory.
SCRIPT=Metadata_Scanner.sh # Sets the script's name.
DOWNLOADEDIMAGES=$DIRPATH/Downloaded_Images # Sets the Downloaded Images directory.
STEPS=$DIRPATH/Steps.log # Sets the completed steps log file.
DB=$DIRPATH/URLs.db # Sets the database location.
PWD=$(pwd) # Sets the current working directory as variable.
USER=$(whoami) # Sets the current user as variable.

# Start of infinite Loop (The infinite scan):
function SCAN {
  echo "$(date -u): [!] [STARTING] SCAN." | tee -a $STEPS
  while [[ true ]]; do
      for FULLURL in $(cat $DB | grep -v '#'); do # greps only URLs.
        echo "Downloading from $FULLURL to Downloaded_Images..."
        # Downloads images only from the URLs:
        wget -e robots=off -nd -r -q --mirror --no-cookies --level=inf --no-check-certificate --no-cache -T 30 --ignore-length -np -P $DOWNLOADEDIMAGES -A jpeg,jpg,bmp,gif,png,webp,exif,tiff,webp,heif,bat $FULLURL 2>/dev/null # (-e: Execute - no robots file, -nd: No Directories, -r: Recursive, -q: Quiet, no output, --level: Recursive depth level=infinite, -T: Timeout <secs>, --ignore-length, -np: No accend to Parent directory, -P: Prefix location)
        rm $DOWNLOADEDIMAGES/*.tmp 2>/dev/null # Removes .tmp files before scanning.
        rm $DIRPATH/wget-log* 2>/dev/null

        # Checks if images scanned before. If yes - removes them.
        for IMAGE in $(ls $DOWNLOADEDIMAGES); do
          HASH1=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' 2>/dev/null) # Sets sha256 hash variable.
          HASHINFILE1=$(cat $DIRPATH/Logs/GPS_Metadata/Scanned_GPS_Hashes.lst 2>/dev/null | grep -c $HASH1) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE1 -eq 1 ]]; then
            rm $DOWNLOADEDIMAGES/$IMAGE # Removes the image.
          fi
        done
        # Checks if images scanned before. If yes - removes them.
        for IMAGE in $(ls $DOWNLOADEDIMAGES); do
          HASH2=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' 2>/dev/null) # Sets sha256 hash variable.
          HASHINFILE2=$(cat $DIRPATH/Logs/Hidden_Data/Scanned_Hidden_Data_Hashes.lst 2>/dev/null | grep -c $HASH2) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE2 -eq 1 ]]; then
            rm $DOWNLOADEDIMAGES/$IMAGE # Removes the image.
          fi
        done

        # Exiftool scan:
        for IMAGE in $(ls $DOWNLOADEDIMAGES); do # For every image - do commands:
          HASH1=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}') # Sets sha256 hash variable.
          HASHINFILE1=$(cat $DIRPATH/Logs/GPS_Metadata/Scanned_GPS_Hashes.lst 2>/dev/null | grep -c $HASH1) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE1 -eq 0 ]]; then # If the hash never occured in the file - do commnads.
            if [[ $(exiftool $DOWNLOADEDIMAGES/$IMAGE | grep 'GPS\|File Name' | wc -l) -gt "1" ]]; then # If line count is > 1 - do commands.
              echo "[!] [FOUND]: $IMAGE from $FULLURL has the following GPS Metadata:" >> $DIRPATH/Logs/GPS_Metadata/GPS_Metadata.log # Logs the file name in the log.
              exiftool $DOWNLOADEDIMAGES/$IMAGE | grep 'GPS\|File Name' >> $DIRPATH/Logs/GPS_Metadata/GPS_Metadata.log # Outputs the exiftool output with just the File Name & GPS info to the log.
              cp $DOWNLOADEDIMAGES/$IMAGE $DIRPATH/Logs/GPS_Metadata # Copies the suspicious image to a folder.
              echo "[>] [COPIED]: $IMAGE to Logs/GPS_Metadata for further analysis." >> $DIRPATH/Logs/GPS_Metadata/GPS_Metadata.log
              echo "" >> $DIRPATH/Logs/GPS_Metadata/GPS_Metadata.log # Just to seperate the outputs.
              sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' >> $DIRPATH/Logs/GPS_Metadata/Scanned_GPS_Hashes.lst # Logs the sha256 hash to the Scanned_GPS_Hashes.lst file.
            else
              sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' >> $DIRPATH/Logs/GPS_Metadata/Scanned_GPS_Hashes.lst # Logs the sha256 hash to the Scanned_GPS_Hashes.lst file.
            fi
          fi
        done # End for IMAGE loop. (exiftool)

        # Binwalk scan:
        for IMAGE in $(ls $DOWNLOADEDIMAGES); do # For every image - do commands:
          HASH2=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}') # Sets sha256 hash variable.
          HASHINFILE2=$(cat $DIRPATH/Logs/Hidden_Data/Scanned_Hidden_Data_Hashes.lst 2>/dev/null | grep -c $HASH2) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE2 -eq 0 ]]; then # If the hash never occured in the file - do commnads.
            if [[ $(binwalk $DOWNLOADEDIMAGES/$IMAGE | wc -l) -gt "6" ]]; then # If binwalk outputs more than 5 lines than - do commands.
              echo "[!] [FOUND]: suspicious file: $IMAGE from $FULLURL, you might want to inspect it further:" >> $DIRPATH/Logs/Hidden_Data/Hidden_Data.log # Logs the suspicious file in the log.
              binwalk $DOWNLOADEDIMAGES/$IMAGE >> $DIRPATH/Logs/Hidden_Data/Hidden_Data.log # Outputs the binwalk output to the log.
              cp $DOWNLOADEDIMAGES/$IMAGE $DIRPATH/Logs/Hidden_Data # Copies the suspicious image to a folder.
              echo "[>] [COPIED]: $IMAGE to Logs/Hidden_Data for further analysis" >> $DIRPATH/Logs/Hidden_Data/Hidden_Data.log
              echo "" >> $DIRPATH/Logs/Hidden_Data/Hidden_Data.log # Just to seperate the outputs.
              sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' >> $DIRPATH/Logs/Hidden_Data/Scanned_Hidden_Data_Hashes.lst # Logs the sha256 hash to the Scanned_Hidden_Data_Hashes.lst file.
            else
              sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' >> $DIRPATH/Logs/Hidden_Data/Scanned_Hidden_Data_Hashes.lst # Logs the sha256 hash to the Scanned_Hidden_Data_Hashes.lst file.
            fi
          fi
        done # End for IMAGE in loop. (binwalk)
      done # End for FULLURL loop.
  done # End of while true loop.
}

# Introduction of the script:
function BEGINNING {
  echo "===========================================================================" | tee -a $STEPS
  figlet "Metadata Finder" -c | tee -a $STEPS
  echo "===========================================================================" | tee -a $STEPS
  echo "$(date -u): [>] [STARTED]: BEGINNING." | tee -a $STEPS
  tput bold && echo "The following script does the following:" && tput sgr0
  echo "1.  Installs Nipe (Anonymity) and activates it.
2.  Installs ExifTool if you don't have it.
3.  Making sure that Nipe is active before starting the script.
4.  Creating necessary directories and sub-directories in the parent directory (Project_Metadata)
5.  Downloads images from websites of your choice. (You can add URLs as you see fit without stopping the script - See 'URLs.db' file for more info)
6.  Scans all images with Exiftool for GPS metadata. If any is found - copies the images to another directory for further analysis.
7.  Scans all images with Binwalk for hidden data. If any is found - copies the images to another directory for further analysis.
8.  Skips images that it had scanned before, saving time and power.
9.  Removes images that it had scanned before.
10. The script creates another script (Continue_After_Reboot.sh) that starts the Metadata_Scanner from the last point it was terminated and in background.
For more information about how to properly use and work with the script - see 'User Manual.pdf' file."
  sleep 20
  tput bold && echo "Would you like to start or exit? (Type 1 or 2)" && tput sgr0
  select yn in "Start" "Exit"; do
      case $yn in
          Start ) break;;
          Exit ) exit;;
      esac
  done
  echo "$(date -u): [V] [COMPLETED]: BEGINNING." | tee -a $STEPS
  sleep 4
}

# ExifTool installation:
function EXIFTOOL {
  cd $HOME # Installation directory.
  echo "Downloading and Installing ExifTool..."
  sleep 3
  wget https://exiftool.org/Image-ExifTool-12.01.tar.gz
  gzip -dc Image-ExifTool-12.01.tar.gz | tar -xf -
  cd Image-ExifTool-12.01
  perl Makefile.PL
  make test
  make install
  rm -rf Image-ExifTool-12.01* # Removes any installation files leftovers.
  cd $PWD
}

# Run only with root privileges user statement:
function ROOT {
  tput bold && echo "The script runs only with root privileges user." && tput sgr0
  echo "If you are not using root privileges user the script will exit on it's own."
  sleep 3
  if [[ ! $(perl -n -e '@user = split /:/ ; print "@user[0]\n" if @user[2] == "0";' < /etc/passwd) =~ "$USER" ]]; then # If current user is not in the root privileges users list then - do commands.
    echo "Not running with root privileges. Log in with root privileges user and try again."
    echo "Exiting..."
    sleep 3
    exit
  fi
  echo "$(date -u): [V] [COMPLETED]: ROOT." | tee -a $STEPS
  sleep 3
}

# Creating a sub-script to make it run in the background:
function REBOOT {
  touch $DIRPATH/Background_Metadata_Scanner.sh # Creats empty file.
  echo '#!/bin/bash' >> $DIRPATH/Background_Metadata_Scanner.sh
  echo "xterm -hold -T Metadata\ Scanner -e echo 'Welcome Back!
The script will start itself and resume the scan in the background as soon as you close the terminal.
Good to Know:
1.  Command: \"ps aux | grep Metadata_Scanner\" = Check what process #ID the script got in the running processes list.
2.  Command: \"kill <process #ID>\" = Terminate the process and stop the scan.
3.  View the Logs directory to check progress.
To resume the scan, you may close the terminal now.'" >> $DIRPATH/Background_Metadata_Scanner.sh
  echo "bash $DIRPATH/$SCRIPT &>/dev/null & disown" >> $DIRPATH/Background_Metadata_Scanner.sh
  chmod a+rx $DIRPATH/Background_Metadata_Scanner.sh
  echo "[+] [CREATED]: Background_Metadata_Scanner.sh file. Run it to continue the script after reboot."
  echo "$(date -u): [V] [COMPLETED]: REBOOT." | tee -a $STEPS
  sleep 3
}

# Nipe Installation:
function NIPE {
  echo "Installing Nipe (for Anonymity)..."
  sleep 3
  # Cloning Nipe to current working directory and cd to nipe:
  export PERL_MM_USE_DEFAULT=1
  cd $DIRPATH
  git clone -q https://github.com/GouveaHeitor/nipe
  NIPEDIR=$(find $DIRPATH -type d -name nipe 2>/dev/null) # Nipe's Directory.
  cd $NIPEDIR

  # Installs libs and dependencies:
  cpan install Try::Tiny Config::Simple JSON

  # Nipe installation:
  cd $NIPEDIR
  perl nipe.pl install
  echo "[+] [INSTALLED]: Nipe."
  echo "$(date -u): [V] [COMPLETED]: NIPE." | tee -a $STEPS
  cd $PWD
  sleep 3
}

# Anonymity check before running the script:
function ANONYMITY {
  NIPEDIR=$(find $DIRPATH -type d -name nipe 2>/dev/null) # Nipe's Directory.
  echo "Checking if Nipe is activated... If not - i will do it for you..."
  until [[ $(cd $NIPEDIR && perl nipe.pl status | grep Status | awk '{print $3}') == "activated." ]]; do # Until Nipe's status is "activated" - do commands:
    cd $NIPEDIR
    ./nipe.pl restart
    cd $PWD
  done
  echo "[>] [STARTED]: Nipe."
  echo "$(date -u): [V] [COMPLETED]: ANONYMITY." | tee -a $STEPS
  sleep 3
}

# Creating logs files and folders:
function LOGSMAKER {
  mkdir $DIRPATH/Logs $DIRPATH/Logs/GPS_Metadata $DIRPATH/Logs/Hidden_Data && touch $DIRPATH/Logs/GPS_Metadata/GPS_Metadata.log $DIRPATH/Logs/Hidden_Data/Hidden_Data.log
  echo "[+] [CREATED]: 'Logs' directory.
[+] [CREATED]: 'GPS_Metadata' and 'Hidden_Data' directories under 'Logs'.
[+] [CREATED]: 'GPS_Metadata.log' and 'Hidden_Data.log' log files."
  echo "$(date -u): [V] [COMPLETED]: LOGSMAKER." | tee -a $STEPS
  sleep 3
}

# Checking at what stage the script ended last time and continuing:
if [[ -f $STEPS ]]; then # If the Steps.log file exists - do commands:
  echo "Welcome Back!
The script will start itself and resume the scan in a moment."
sleep 3
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "BEGINNING" ]]; then
    ROOT
    REBOOT
    NIPE
    ANONYMITY
    LOGSMAKER
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "ROOT" ]]; then
    REBOOT
    NIPE
    ANONYMITY
    LOGSMAKER
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "REBOOT" ]]; then
    NIPE
    ANONYMITY
    LOGSMAKER
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "NIPE" ]]; then
    ANONYMITY
    LOGSMAKER
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "ANONYMITY" ]]; then
    ANONYMITY # Only to check if you are anonymous again.
    LOGSMAKER
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "LOGSMAKER" ]]; then
    ANONYMITY # Only to check if you are anonymous again.
    SCAN
  fi
  if [[ $(cat $STEPS | awk 'END {print $NF}' | sed -e 's/\.//g') == "SCAN" ]]; then
    ANONYMITY # Only to check if you are anonymous again.
    SCAN
  fi
else # If Steps.log not found - do commands: (This is the actual starting point from 0)
  BEGINNING
  echo "Cheking if ExifTool is Installed.
If not - it will be installed automatically."
  sleep 3
  exiftool && echo "[V] ExifTool is Installed. Continuing..." || EXIFTOOL # Run ExifTool. If command is available - move on. If command outputs an error - runs the EXIFTOOL function.
  ROOT
  REBOOT
  NIPE
  ANONYMITY
  LOGSMAKER
  SCAN
fi
