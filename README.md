# Metadata-Scanner                                                                      
A code that scans pictures from URLs of a database and finds if there is hidden data and GPS coordinates.


# Description:
The script does the following:
1.  Installs Nipe (Anonymity) and activates it.
2.  Installs ExifTool if you don't have it.
3.  Makes sure that Nipe is active before starting the script.
4.  Creating necessary directories and sub-directories in the parent directory (Project_Metadata)
5.  Downloads images from websites of your choice. (You can add URLs as you see fit without stopping the script - See 'URLs.db' file for more info)
6.  Scans all images with Exiftool for GPS metadata. If any is found - copies the images to another directory for further analysis.
7.  Scans all images with Binwalk for hidden data. If any is found - copies the images to another directory for further analysis.
8.  Skips images that it had scanned before, saving time and power.
9.  Removes images that it had scanned before.
10. The script creates another script (Continue_After_Reboot.sh) that starts the Metadata_Scanner from the last point it was terminated and in background.
For more information about how to properly use and work with the script - see 'User Manual.pdf' file.
