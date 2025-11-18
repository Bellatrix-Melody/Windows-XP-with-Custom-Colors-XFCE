#!/bin/bash

#This converter function was taken from https://codeberg.org/z3rOR0ne/dyetide/src/branch/main/dyetide and edited to only convert and output the necessary HSL color needed for the rest of the script, so thanks z3rOR0ne!

#converter helpers

error() {
    printf "error: %s\n" "$1" 1>&2
    exit 2
}

dec_to_float() {
    echo "scale=8; $1 / 255" | bc -l
}

find_min_max() {
    max=$1
    min=$1
    for arg in "$@"
    do
        if [[ "$(echo "$arg > $max" | bc -l)" -eq 1 ]]; then
            max=$arg
        elif [[ "$(echo "$arg < $max" | bc -l)" -eq 1 ]]; then
            min=$arg
        fi
    done
}

calculate_saturation() {
    local min=$1
    local max=$2
    local l=$3
    # if rgb all have same values, then color is grey and saturation is 0
    if [[ $(echo "$max == $min" | bc -l) -eq 1 ]]; then
        printf "%.0f" 0
    else
        # if value (lightness) is less than 50%, then lightness is a percentage determined
        # based off of $max and $min
        if [[ $(echo "$l < 50" | bc -l) -eq 1 ]]; then
            printf "%.0f" "$(echo "scale=8; (($max - $min) / ($max + $min) * 100)" | bc -l)"
        # else a subtractive calculation is used using $max and $min to determine percentage
        else
            printf "%.0f" "$(echo "scale=8; (($max - $min) / (2 - $max - $min) * 100)" | bc -l)"
        fi
    fi
}

calculate_hue() {
    local min=$1
    local max=$2
    # if rgb all have same values, then color is grey and lightness is 0
    if [[ $(echo "$max == $min" | bc -l) -eq 1 ]]; then
        printf "%.0f" 0
    else
        # determines which of r,g,b is predominant color and reallocates hue
        # degree number based off of it
        if [[ $(echo "$r == $max" | bc -l) -eq 1 ]]; then
            printf "%.0f" "$(echo "scale=8; 60 * (($g - $b) / ($max - $min))" | bc -l)"
        elif [[ $(echo "$g == $max" | bc -l) -eq 1 ]]; then
            printf "%.0f" "$(echo "scale=8; 60 * (($b - $r) / ($max - $min)) + 120" | bc -l)"
        else
            printf "%.0f" "$(echo "scale=8; 60 * (($r -$g) / ($max - $min)) + 240" | bc -l)"
        fi
    fi
}


converter(){
#checking color validity and converting to RGB

if ((${#hex} == 6)); then
        ((r = 16#${hex:0:2}, g = 16#${hex:2:2}, b = 16#${hex:4:2}))

else
    error "$hex is not a recognized hex color code. ${#hex}"
fi

#The actual Conversion(tm)

r=$(dec_to_float "$r")
g=$(dec_to_float "$g")
b=$(dec_to_float "$b")

find_min_max "$r" "$g" "$b"

# lightness is calculated as a percentage between max and min values of rgb
l=$(printf "%.0f" "$(echo "scale=8; (($max + $min) / 2 * 100)" | bc -l)")

# saturation is then calculated based off of $min/$max/$l values
s=$(calculate_saturation "$min" "$max" "$l")

# hue is calculated based off of $min/$max values
h=$(calculate_hue "$min" "$max")

#h is added 360 degrees if a negative value is passed
if [[ $(echo "$h < 0" | bc -l) -eq 1 ]]; then
    h=$(echo "scale=8; $h + 360" | bc -l)
fi

# prints final hsl(a) result

echo "$h $s $l"

}
converter2(){
#checking color validity and converting to RGB


if ((${#msnotblue} == 8)); then
        ((r = 16#${msnotblue:0:2}, g = 16#${msnotblue:2:2}, b = 16#${msnotblue:4:2}, a = 16#${msnotblue:6:2}))
        a=$(printf "%.2f" "$(dec_to_float "$a")")
    elif ((${#msnotblue} == 6)); then
        ((r = 16#${msnotblue:0:2}, g = 16#${msnotblue:2:2}, b = 16#${msnotblue:4:2}))
    elif ((${#msnotblue} == 3)); then
        ((r = 16#${msnotblue:0:1}, g = 16#${msnotblue:1:1}, b = 16#${msnotblue:2:1}))


else
    error "$msnotblue is not a recognized hex color code. ${#msnotblue}"
fi

#The actual Conversion(tm)

r=$(dec_to_float "$r")
g=$(dec_to_float "$g")
b=$(dec_to_float "$b")

find_min_max "$r" "$g" "$b"

# lightness is calculated as a percentage between max and min values of rgb
l=$(printf "%.0f" "$(echo "scale=8; (($max + $min) / 2 * 100)" | bc -l)")

# saturation is then calculated based off of $min/$max/$l values
s=$(calculate_saturation "$min" "$max" "$l")

# hue is calculated based off of $min/$max values
h=$(calculate_hue "$min" "$max")

#h is added 360 degrees if a negative value is passed
if [[ $(echo "$h < 0" | bc -l) -eq 1 ]]; then
    h=$(echo "scale=8; $h + 360" | bc -l)
fi

# prints final hsl(a) result

echo "$h $s $l" 

}

converterswatch(){
#checking color validity and converting to RGB

if ((${#swatchhex} == 6)); then
        ((r = 16#${swatchhex:0:2}, g = 16#${swatchhex:2:2}, b = 16#${swatchhex:4:2}))

else
    error "$swatchhex is not a recognized hex color code. ${#swatchhex}"
fi

#The actual Conversion(tm)

r=$(dec_to_float "$r")
g=$(dec_to_float "$g")
b=$(dec_to_float "$b")

find_min_max "$r" "$g" "$b"

# lightness is calculated as a percentage between max and min values of rgb
l=$(printf "%.0f" "$(echo "scale=8; (($max + $min) / 2 * 100)" | bc -l)")

# saturation is then calculated based off of $min/$max/$l values
s=$(calculate_saturation "$min" "$max" "$l")

# hue is calculated based off of $min/$max values
h=$(calculate_hue "$min" "$max")

#h is added 360 degrees if a negative value is passed
if [[ $(echo "$h < 0" | bc -l) -eq 1 ]]; then
    h=$(echo "scale=8; $h + 360" | bc -l)
fi

# prints final hsl(a) result

echo "$h" "$s%" "$l%"

}

#user input fields

echo "enter file name for your test color swatch located in /colortest"
read swatch 

swatchhex=$(magick /colortest/$swatch -scale 1x1! -format "%[hex:u.p]\n" info:)

read sourceH sourceS sourceL < <(converterswatch)


echo "enter the hex code for your new color i.e. the color you want your image to become with no starting # i.e. 99D2D3"
read hex

read targetH targetS targetL < <(converter)

echo "go to https://r0d3r1ck0rd0n3z.github.io/ImageMagick-Modulate-Calculator/ and plug these numbers"
echo ""

echo "In field A enter:"
echo "hsl($sourceH,100%,50%)"
echo ""

echo "In field B, section 2 enter:"
echo "hsl($targetH,100%,50%)"
echo ""

echo "Enter the third number after the -modulate e.g. convert input.png -modulate 100,100,138 <-- this is the number you enter"
echo "Enter number:"
read convertedH

read targetH targetS targetL < <(converter)

echo "Checking S"

testS=0
magickS=0

until [[ $magickS -eq $targetS ]]
do
    magick $swatch -set option:modulate:colorspace hsl -modulate 100,$testS,$convertedH stest.png
    msnotblue=$(magick /colortest/stest.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickH magickS magickL < <(converter2)
    ((testS++))
      
done

convertedS=$testS

echo "Checking L"

testL=0
magickL=0

until [[ $magickL -eq $targetL ]]
do
    magick $swatch -set option:modulate:colorspace hsl -modulate $testL,$convertedS,$convertedH ltest.png
    msnotblue=$(magick /colortest/ltest.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickH magickS magickL < <(converter2)
    ((testL++))  
done

convertedL=$testL

echo "Your command in magick will be the following:"
echo "magick input.png -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH output.png"

