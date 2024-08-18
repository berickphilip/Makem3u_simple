#!/bin/bash

# Check if there are any .chd or .rvz files in the current directory
files=(*.chd *.rvz)
if [ ${#files[@]} -eq 0 ]; then
    echo "No .chd or .rvz files found in the current directory."
    exit 1
fi

# Function to get the base game name (without disc number and extension)
get_basename() {
    echo "$1" | sed -E 's/ \([Dd]isc [0-9]+\)\.(chd|rvz)$//' | sed 's/\.\.\.$//' | sed 's/[[:space:]]*$//'
}

# Process each .chd or .rvz file and group by base name
declare -A games
for file in "${files[@]}"; do
    basename=$(get_basename "$file")
    echo "Processing file: '$file' (Base name: '$basename')"  # Debugging output
    games["$basename"]+="$file"$'\n'
done

# Create a folder and .m3u file for each game with multiple discs
for game in "${!games[@]}"; do
    # Get the list of discs for the current game
    disk_list=$(echo -e "${games[$game]}" | sort)

    # Count the number of discs
    num_disks=$(echo "$disk_list" | wc -l)

    echo "Game: '$game', Number of Discs: $num_disks"  # Debugging output

    # Clean up game name for directory and file creation
    clean_game_name=$(echo "$game" | sed 's/[[:space:]]$//' | sed 's/\.[cC][hH][dD]$//' | sed 's/\.[rR][vV][zZ]$//')

    # Add the .m3u extension to the folder name
    folder_name="${clean_game_name}.m3u"

    # Create a folder for the game with the .m3u extension
    mkdir -p "$folder_name"

    # Move the discs into the game's folder
    echo "$disk_list" | while IFS= read -r disc; do
        echo "Moving '$disc' to '$folder_name/'"  # Debugging output
        mv -- "$disc" "$folder_name/"
    done

    # Only create .m3u file if there is more than one disc
    if [ "$num_disks" -gt 1 ]; then
        # Create the .m3u file with the same name as the folder
        m3u_file="${folder_name}/${clean_game_name}.m3u"

        # Write the full filenames (with extensions) to the .m3u file
        echo "$disk_list" | while IFS= read -r line; do
            echo "$(basename "$line")" >> "$m3u_file"
        done

        echo "Created $m3u_file with the following discs:"
        cat "$m3u_file"
    else
        echo "Skipping ${game} - only one disc found."
    fi
done

# Exit the script
exit 0
