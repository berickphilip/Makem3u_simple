#!/bin/bash

# Check if there are any .chd files in the current directory
chd_files=(*.chd)
if [ ${#chd_files[@]} -eq 0 ]; then
    echo "No .chd files found in the current directory."
    exit 1
fi

# Function to get the base name (without disc number and extension)
get_basename() {
    echo "$1" | sed -E 's/(.*) \([Dd]isc [0-9]+\)\.chd/\1/' | sed 's/\.\.\.$//' | sed 's/[[:space:]]*$//'
}

# Process each .chd file and group by base name
declare -A games
for chd_file in "${chd_files[@]}"; do
    basename=$(get_basename "$chd_file")
    echo "Processing file: '$chd_file' (Base name: '$basename')"  # Debugging output
    games["$basename"]+="$chd_file"$'\n'
done

# Create a folder and .m3u file for each game with multiple discs
for game in "${!games[@]}"; do
    # Get the list of discs for the current game
    disk_list=$(echo -e "${games[$game]}" | sort)
    
    # Count the number of discs
    num_disks=$(echo "$disk_list" | wc -l)
    
    echo "Game: '$game', Number of Discs: $num_disks"  # Debugging output
    
    # Clean up game name for directory creation
    clean_game_name=$(echo "$game" | sed 's/[^a-zA-Z0-9 ]/_/g' | sed 's/[[:space:]]*$//')
    
    # Add the .m3u extension to the folder name
    folder_name="${clean_game_name}.m3u"
    
    # Create a folder for the game with .m3u extension
    mkdir -p "$folder_name"
    
    # Move the discs into the game's folder
    echo "$disk_list" | while IFS= read -r disc; do
        echo "Moving '$disc' to '$folder_name/'"  # Debugging output
        mv -- "$disc" "$folder_name/"
    done
    
    # Only create .m3u file if there are more than one disc
    if [ "$num_disks" -gt 1 ]; then
        # Create the .m3u file without adding the extension again
        m3u_file="${folder_name}/${clean_game_name}.m3u"
        
        # Write the list of discs to the .m3u file
        echo "$disk_list" | sed "s#^#$folder_name/#" > "$m3u_file"
        
        echo "Created $m3u_file with the following discs:"
        cat "$m3u_file"
    else
        echo "Skipping ${game} - only one disc found."
    fi
done

# Exit the script
exit 0
