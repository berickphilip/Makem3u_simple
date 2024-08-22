This is a copy of the excellent script that I found by https://github.com/HonestMike/Makem3u

That script generates M3U files from CHD files that are found in the same folder, including multi-dics games!

However I changed two things from the original script:

1 - The original script places the CHD files and M3U files in individual folders, and since personally I don't use that type of structure I removed that step. So all CHD and all M3U files are still in the same folder.

2 - The M3U files created by the original script have an initial blank line, and I added a command at the end of the script to remove any initial blank lines from inside the generated M3U files.
