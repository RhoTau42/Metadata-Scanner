# Metadata-Scanner                                                                      
A script to find GPS metadata and hidden data within images from webpages recursively.

## Usage:
  1. Modify the URLs.db to your liking (Sites that you want to scan).
  2. run `./Metadata_scanner`
  3. run `./scan.sh`
  
  Make sure you have the URL.db file in the same directory.
  
  **DO NOT CHANGE THE DIRECTORY NAME `Metadata-Scanner` AS IT'S HARD-CODED IN THE SCRIPT**
  
  **DO NOT PUT THE SCRIPT IN A DIRECTORY WITH SPACES - THE SCRIPT WILL BREAK IF YOU WILL**
  
  **Good:** `/root/home/Desktop/Metadata-Scanner/Metadata_Scanner.sh`
  
  **Bad:** `/root/home/Desktop/Some\ Directory\ with\ spaces/Metadata_Scanner.sh`

## Full Work Flow:
**`Metadata_Scanner.sh` does the following:**
1.  Installs `Nipe` (Anonymity) and activates it.
2.  Installs `ExifTool` if you don't have it.
3.  Makes sure that `Nipe` is active **before** starting the script.
4.  Creating necessary directories and sub-directories in the parent directory (`Metadata-Scanner`)
5.  Downloads images from websites of your choice. (You can add URLs as you see fit without stopping the script - See '`URLs.db`' file for more info)
6.  The script creates another script (`Continue_After_Reboot.sh`) that starts the `Metadata_Scanner` from the last point it was terminated and in background.
For more information about how to properly use and work with the script - **see 'User Manual.pdf' file**.

**`scan.sh` will do the following:**</br>
7.  Scans all images with `Exiftool` for GPS metadata. **If any is found** - copies the images to another directory for further analysis.</br>
8.  Scans all images with `Binwalk` for hidden data. **If any is found** - copies the images to another directory for further analysis.</br>
9.  Skips images that it had scanned before, saving time and power.</br>
10. Removes images that it had scanned before.</br>

