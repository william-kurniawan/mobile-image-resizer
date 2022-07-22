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
    path="assets/vehicles/${arrIN[0]}"
    magick "$f" -resize 210x105 "${path}/android/mdpi/${arrIN[1]}.webp"
    magick "$f" -resize 315x158 "${path}/android/hdpi/${arrIN[1]}.webp"
    magick "$f" -resize 420x210 "${path}/android/xhdpi/${arrIN[1]}.webp"
    magick "$f" -resize 630x315 "${path}/android/xxhdpi/${arrIN[1]}.webp"

    magick "$f" -resize 630x315 "${path}/iOS/1x/${arrIN[1]}.png"
    magick "$f" -resize 420x210 "${path}/iOS/2x/${arrIN[1]}.png"
    magick "$f" -resize 630x315 "${path}/iOS/3x/${arrIN[1]}.png"
    changedCount=$((changedCount+7))
done

if [ "$changedCount" -gt 0 ]; then
  echo "Total images created $changedCount"
  echo "::set-output name=total::$changedCount"
fi
