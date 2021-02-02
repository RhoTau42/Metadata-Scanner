#!/bin/bash

# Basic variables:
echo "Loading... Please hold."
DIRPATH=$(find / -type d -name "Metadata-Scanner" 2>/dev/null) # Sets the location of the script's >
SCRIPT=Metadata_Scanner.sh # Sets the script's name.
DOWNLOADEDIMAGES=$DIRPATH/Downloaded_Images # Sets the Downloaded Images directory.
STEPS=$DIRPATH/Steps.log # Sets the completed steps log file.
DB=$DIRPATH/URLs.db # Sets the database location.
PWD=$(pwd) # Sets the current working directory as variable.
USER=$(whoami) # Sets the current user as variable.
while [[ true ]]; do
        rm $DOWNLOADEDIMAGES/*.tmp 2>/dev/null # Removes .tmp files before scanning.
        rm $DIRPATH/wget-log* 2>/dev/null

        # Checks if images scanned before. If yes - removes them.
        echo "[?] Cheking hashes of GPS scanned files..."
        for IMAGE in $(ls $DOWNLOADEDIMAGES/ | grep -v "*html"); do
          HASH1=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' 2>/dev/null) # Sets sha256 hash variable.
          HASHINFILE1=$(cat $DIRPATH/Logs/GPS_Metadata/Scanned_GPS_Hashes.lst 2>/dev/null | grep -c $HASH1) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE1 -eq 1 ]]; then
            rm $DOWNLOADEDIMAGES/$IMAGE # Removes the image.
            echo "[-] Removed $IMAGE that got scanned for GPS data."
          fi
        done
        # Checks if images scanned before. If yes - removes them.
        echo "[?] Cheking hashes of Hidden Data scanned files..."
        for IMAGE in $(ls $DOWNLOADEDIMAGES/ | grep -v "*html"); do
          HASH2=$(sha256sum $DOWNLOADEDIMAGES/$IMAGE | awk '{print $1}' 2>/dev/null) # Sets sha256 hash variable.
          HASHINFILE2=$(cat $DIRPATH/Logs/Hidden_Data/Scanned_Hidden_Data_Hashes.lst 2>/dev/null | grep -c $HASH2) # Greps the count of how many times the hash occures in the Scanned_GPS_Hashes.log file.
          if [[ $HASHINFILE2 -eq 1 ]]; then
            rm $DOWNLOADEDIMAGES/$IMAGE # Removes the image.
            echo "[-] Removed $IMAGE that got scanned for hidden data."
          fi
        done

        # Exiftool scan:
        #echo "[>] Scans images with ExifTool..."
        for IMAGE in $(ls $DOWNLOADEDIMAGES/ | grep -v "*html"); do # For every image - do commands:
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
        echo "[>] Scans images with Binwalk..."
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
	sleep 2
      done # End for FULLURL loop.
  done # End of while true loop.
