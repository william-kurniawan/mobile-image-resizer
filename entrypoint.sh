#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]  || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] || [ -z "$6" ] || [ -z "$7" ] || [ -z "$8" ]  || [ -z "$9" ]; then
  echo "Please provide all variables"
  exit 1;
fi

sourceVehicles=$1
sourceVehicleClasses=$2
scaleMhdpi=$3
scaleHdpi=$4
scaleXhdpi=$5
scaleXxhdpi=$6
scale1x=$7
scale2x=$8
scale3x=$9

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
    magick "$f" -resize "${scaleMhdpi}" "${path}/android/mdpi/${arrIN[1]}.webp"
    magick "$f" -resize "${scaleHdpi}" "${path}/android/hdpi/${arrIN[1]}.webp"
    magick "$f" -resize "${scaleXhdpi}" "${path}/android/xhdpi/${arrIN[1]}.webp"
    magick "$f" -resize "${scaleXxhdpi}" "${path}/android/xxhdpi/${arrIN[1]}.webp"

    magick "$f" -resize "${scale1x}"  "${path}/iOS/1x/${arrIN[1]}.png"
    magick "$f" -resize "${scale2x}"  "${path}/iOS/2x/${arrIN[1]}.png"
    magick "$f" -resize "${scale3x}"  "${path}/iOS/3x/${arrIN[1]}.png"
    changedCount=$((changedCount+7))
done

if [ "$changedCount" -gt 0 ]; then
  echo "Total images created $changedCount"
  echo "::set-output name=total::$changedCount"
fi
