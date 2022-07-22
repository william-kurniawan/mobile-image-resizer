#!/bin/bash

set -e

sourceVehicles=${SOURCE_VEHICLES:-src/vehicles}
sourceVehicleClasses=${SOURCE_VEHICLE_CLASSES:-src/vehicleClasses}

imagecount=$(find "$sourceVehicles" -regextype posix-extended -regex '.*\.(jpg|png|jpeg|webp)' | wc -l)

if [ -d "$sourceVehicles" ]; then
  true
else
  echo "Error: ${sourceVehicles} does not exist"
  exit 1
fi

echo "Image count in directory: $imagecount"

if [ "$imagecount" -eq "0" ]; then
   echo "No images found in $sourceVehicles";
   exit 1;
fi

mapfile -t imagearray < <(find "$sourceVehicles" -regextype posix-extended -regex '.*\.(jpg|png|jpeg|webp)')

changedCount=0
for f in "${imagearray[@]}"; do
    filename="$(basename "$f" | sed 's/\(.*\)\..*/\1/')"
    echo "filename: $filename"
    arrIN=(${filename//_/ })
    resolutions=( "android/mdpi" "android/hdpi" "android/xhdpi" "android/xxhdpi" "iOS/1x" "iOS/2x" "iOS/3x") 
    for r in "${resolutions[@]}"
    do
      echo "$r"
      path="assets/vehicles/${arrIN[0]}/${r}"
      gitkeep="${path}/.gitkeep"
      if [ -d "$path" ]; then
        echo "Destination path exists"
        true
      else
        echo "Create destination path $gitkeep"
        mkdir -p -- "${gitkeep%/*}" && touch -- "$gitkeep"
        changedCount=$((changedCount+1))
      fi
    done
done

if [ "$changedCount" -gt 0 ]; then
    git add --all
fi
