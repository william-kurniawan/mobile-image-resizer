#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Please provide all variables"
  exit 1;
fi

sourceVehicles=$1
sourceVehicleClasses=$2

echo "sourceVehicles: $1"
echo "sourceVehicleClasses: $2"

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
    echo "Resize $f"
    resolutions=( "android/mdpi" "android/hdpi" "android/xhdpi" "android/xxhdpi" "iOS/1x" "iOS/2x" "iOS/3x") 
    for r in "${resolutions[@]}"; do
      path="assets/vehicles/${arrIN[0]}/${r}"
      mogrify -resize 210x105 -quality 100 -path ${path} "$f"
      mogrify -resize 315x158 -quality 100 -path ${path} "$f"
      mogrify -resize 420x210 -quality 100 -path ${path} "$f"
      mogrify -resize 630x315 -quality 100 -path ${path} "$f"

      mogrify -resize 630x315 -quality 100 -path ${path} "$f"
      mogrify -resize 420x210 -quality 100 -path ${path} "$f"
      mogrify -resize 630x315 -quality 100 -path ${path} "$f"
      changedCount=$((changedCount+7))
    done
done

if [ "$changedCount" -gt 0 ]; then
  echo "Total images created $changedCount"
  echo "::set-output name=total::$changedCount"
fi
