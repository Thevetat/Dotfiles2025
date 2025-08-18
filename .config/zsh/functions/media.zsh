#*
## Name: 
## Desc: 
## Inputs:
## Usage:
resizejpg() {
    for i in *.jpg; 
        do name=`echo $i | cut -d'.' -f1`;
        echo $name;
        convert $i -resize "$*"% $name.jpg;
    done
}
#*

#*
## Name: 
#
## Desc: 
## Inputs:
## Usage:
htj() {
    heif-convert -q 75 $1.heic $2.jpg
}
#*

#*
## Name: 
## Desc: 
## Inputs:
## Usage:
convmp4() {
    for i in *.mp4; 
        do name=`echo $i | cut -d'.' -f1`;
        echo $name;
        ffmpeg -c:v h264_cuvid -i $i -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le $name.mov;
    done
}
#*

preupscale() {
  input_file=$1
  preup_file="${input_file%.*}.mp4"

  # Copy the preupscaled file to the pre-upscale folder
  destination_folder="pre-upscale"

  if [[ ! -d $destination_folder ]]; then
    mkdir $destination_folder
  fi

  cp "$preup_file" "$destination_folder"
}

preup() {
  find . -type f -name '*.mp4' -print0 | while read -d '' -r file; do
    preupscale "$file"
  done
}

#*
## Name: ConvertAndDelete
## Desc: Find all PNG files, convert them to WEBP and then delete the original PNG files
## Inputs: None
## Usage: ConvertAndDelete
pngtowebp() {
    find . -type f -name "*.png" -print0 | while IFS= read -r -d '' file; do
        local webp_file="${file%.png}.webp"
        convert "$file" "$webp_file" && rm -f "$file"
    done
}
#*