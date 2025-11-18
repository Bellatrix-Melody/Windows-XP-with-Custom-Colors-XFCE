#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
RED='\033[0;31m'
# This array is a hue wheel based off msblue.png instead of red and converted to a 0-200 scale so that it can be input into image magick credit. The formula to do this was pulled from https://github.com/r0d3r1ck0rd0n3z/ImageMagick-Modulate-Calculator/blob/master/script.js I just made it into an array, so thanks r0d3r1ck0rd0n3z!
#How I found the base HSL of msblue.png was using the following command on the base RedmondXP taskbar.png (in gtk-3.0/assets)"magick taskbar.png -scale 1x1! -format "%[hex:u.p]\n" info:" this gave me a hex code, so I ran it through the converter below to get the base HSL value
#If you want to start from a different base HSL value you can use Magick_Hex_to_HSL.sh comment out the line below, the line "convertedH=${H_array[$targetH]}" further down and uncomment the line below that. It won't build you a new array but it's something'

#custom_start_hue=[insert your custom hue value here]
H_array=(
  177 178 178 179 179 180 181 181 182 182 183 183 184 184 185 186 186
  187 187 188 188 189 189 190 191 191 192 192 193 193 194 194 195 196
  196 197 197 198 198 199 199 0 1 2 2 3 3 4 4 5 5 6 7 7 8 8 9 9 10 10
  11 12 12 13 13 14 14 15 15 16 17 17 18 18 19 19 20 20 21 22 22 23 23
  24 24 25 25 26 27 27 28 28 29 29 30 30 31 32 32 33 33 34 34 35 35 36
  37 37 38 38 39 39 40 40 41 42 42 43 43 44 44 45 45 46 47 47 48 48 49
  49 50 50 51 52 52 53 53 54 54 55 55 56 57 57 58 58 59 59 60 60 61 62
  62 63 63 64 64 65 65 66 67 67 68 68 69 69 70 70 71 72 72 73 73 74 74
  75 75 76 77 77 78 78 79 79 80 80 81 82 82 83 83 84 84 85 85 86 87 87
  88 88 89 89 90 90 91 92 92 93 93 94 94 95 95 96 97 97 98 98 99 99 100
  100 100 101 101 102 102 103 103 104 104 105 106 106 107 107 108 108
  109 109 110 111 111 112 112 113 113 114 114 115 116 116 117 117 118
  118 119 119 120 121 121 122 122 123 123 124 124 125 126 126 127 127
  128 128 129 129 130 131 131 132 132 133 133 134 134 135 136 136 137
  137 138 138 139 139 140 141 141 142 142 143 143 144 144 145 146 146
  147 147 148 148 149 149 150 151 151 152 152 153 153 154 154 155 156
  156 157 157 158 158 159 159 160 161 161 162 162 163 163 164 164 165
  166 166 167 167 168 168 169 169 170 171 171 172 172 173 173 174 174
  175 176 176 177
)

H_arrayR=(226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 261 262 263 264 265 266 267 268 269 270 271 272 273 274 275 276 277 278 279 280 281 282 283 284 285 286 287 288 289 290 291 292 293 294 295 296 297 298 299 300 301 302 303 304 305 306 307 308 309 310 311 312 313 314 315 316 317 318 319 320 321 322 323 324 325 326 327 328 329 330 331 332 333 334 335 336 337 338 339 340 341 342 343 344 345 346 347 348 349 350 351 352 353 354 355 356 357 358 359 360 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46)
H_arrayL=(46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226)

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


converter_primary(){
#checking color validity and converting to RGB

if ((${#primary} == 6)); then
        ((r = 16#${primary:0:2}, g = 16#${primary:2:2}, b = 16#${primary:4:2}))

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


converter_tester(){
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


echo "
########################################################################################

                            RedmondXP Custom Color Creator
                                     
########################################################################################"
echo ""
echo -e "${GREEN}Welcome! Let's start with some basic information to get your theme started

Have you run this script before?${NC}"
echo -e "${BLUE}Enter answer:[y/n]${NC}"
read setup

if [[ ${setup} == "n" ]]; then
    echo ""
    echo -e "${GREEN}Fantastic, let's get some dependencies for the tools we'll be using set up'${NC}"
    echo ""
    echo -e "${BLUE}Installing color-converter dependencies${NC}"
    echo ""
    python3 -m venv backgrounds/color_extractor
    source backgrounds/color_extractor/bin/activate
    pip install pillow numpy scikit-learn
    deactivate

    echo ""
    echo -e "${BLUE}Setup complete!${NC}"

    echo ""

elif [[ ${setup} == "y" ]]; then
    echo ""
    echo -e "${GREEN}Skipping setup${NC}"
    echo ""
fi
echo " 
########################################################################################
"

echo -e "${BLUE}Enter your theme name${NC} 
${RED}note: theme names can only contain alpha-numeric characters and must not contain a space ${NC}"
read ThemeName
echo " 
########################################################################################
"

#letting the user choose automation or not
echo -e "${GREEN} This script has a built in python script to create a custom color palette based off of the background image you want to use. 

However, this is opetional so you have three options for how you want to customize your colors${NC}

${GREEN}Option 1: Create a palette of 8 colors using your background image. Then you can chose a primary and secondary color from among them.${NC}

${BLUE}OR${NC}

${GREEN}Option 2: Have the colors chosen for you, with the primary color being the most common color in your image and the secondary being the second most common.

${RED}Be advised: results from this option will vary heavily depending on your background image choice.${NC} 

${BLUE}OR${NC}

${GREEN}Option 3: You already have a custom primary and secondary color in mind and just want to use those${NC}" 


echo -e "${BLUE}Enter your choice (1,2, or 3)${NC}"
read automation_choice

if [[ ${automation_choice} -eq 1 ]]; then
    echo " 
########################################################################################
"
    echo -e "${BLUE}Enter the file name of the image of your desired background in the /backgrounds folder, including the file type Example: image.png ${NC} 
${RED}Note: the name is case sensitive${NC}"
    read background  
    echo ""    
    echo -e "${BLUE}Creating a color palliate based off your background image${NC}"
    echo ""

    source backgrounds/color_extractor/bin/activate
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export QT_LOGGING_RULES="*.debug=false;qt.qpa.*=false"

    # Enable 24-bit color support
    export COLORTERM=truecolor
    export TERM=xterm-256color

    python3 backgrounds/color_extractor.py backgrounds/$background -n 8 -s --output $ThemeName.txt
    deactivate
    echo " 

########################################################################################

"
    echo -e "${GREEN}Choose the two colors you like the most from the above listing of colors${NC}"
    echo ""
    echo -e "${BLUE}Enter a value (1-8) for your primary color:${NC}"
    read primarychoice

    if [[ $primarychoice == 1 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '1p')
    elif [[ $primarychoice == 2 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '2p')
    elif [[ $primarychoice == 3 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '3p')
    elif [[ $primarychoice == 4 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '4p')
    elif [[ $primarychoice == 5 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '5p')
    elif [[ $primarychoice == 6 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '6p')
    elif [[ $primarychoice == 7 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '7p')
    elif [[ $primarychoice == 8 ]]; then
        primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '8p')
    fi    
    echo ""
    echo " 
########################################################################################
"
    echo -e "${BLUE}Enter a value (1-8) for your secondary color:${NC}"
    read secondarychoice

     if [[ $secondarychoice == 1 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '1p')
        elif [[ $secondarychoice == 2 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '2p')
        elif [[ $secondarychoice == 3 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '3p')
        elif [[ $secondarychoice == 4 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '4p')
        elif [[ $secondarychoice == 5 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '5p')
        elif [[ $secondarychoice == 6 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '6p')
        elif [[ $secondarychoice == 7 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '7p')
        elif [[ $secondarychoice == 8 ]]; then
            secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '8p')
    fi

elif [[ ${automation_choice} -eq 2 ]]; then
    echo " 
########################################################################################
"
    echo -e "${BLUE}Enter the file name of the image of your desired background in the /backgrounds folder, including the file type Example: image.png ${NC} 
${RED}Note: the name is case sensitive${NC}"
    read background
    echo ""    
    echo ""
    echo -e "${GREEN}Creating a color palliate based off your background image${NC}"
    echo ""
    echo "" 


    source backgrounds/color_extractor/bin/activate
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export QT_LOGGING_RULES="*.debug=false;qt.qpa.*=false"

    # Enable 24-bit color support
    export COLORTERM=truecolor
    export TERM=xterm-256color

    python3 backgrounds/color_extractor.py backgrounds/$background -n 8 -s --output $ThemeName.txt
    deactivate
    primary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '1p')
    secondary=$(grep -oP 'HEX: #\K[0-9A-Fa-f]+' "$ThemeName.txt" | sed -n '2p')


elif [[ ${automation_choice} -eq 3 ]]; then
    echo " 
########################################################################################
"
    echo -e "${BLUE}Enter your desired primary color as a hex code, minus the pound sign. Example: 99E2E3${NC} "
    read primary
    echo " 
########################################################################################
"    
    echo -e "${BLUE}Enter your desired seconday color as a hex code, minus the pound sign. Example: 99E2E3${NC} "
    read secondary
    echo ""
    
fi

# getting the files in place

echo -e "${BLUE}Making the theme directory in /custom_themes and copying files over${NC}"
if [[ -d "custom-themes/$ThemeName" ]]; then
    rm -r "custom-themes/$ThemeName"
fi
mkdir custom-themes/$ThemeName
cp -r recolor-target/* custom-themes/$ThemeName

echo ""
echo -e "${BLUE}Finding the primary hex color in HSL and converting that to a format that magick will accept.[This may take a while]${NC}"

#finding the primary hex color in HSL and converting that to a format that magick will accept
read targetH targetS targetL < <(converter_primary)



#comment this out if you want to use a custom starting hue
convertedH=${H_array[$targetH]}

hconverter(){
targetindex=-1

for (( i=0; i<${#H_arrayR[@]}; i++ )); 
    do 
        if [[ ${H_arrayR[i]} -eq $targetH ]]; then
            targetindex=$(( i - 1 ))
            targetindex=$(( targetindex * 1000 ))
            targetindex=$(( targetindex / 180 ))
            targetindex=$(( targetindex * 100 ))
            targetindex=$(( targetindex / 1000 ))
            targetindex=$(( targetindex + 100 ))
        fi
    done

for (( i=0; i<${#H_arrayR[@]}; i++ )); 
    do 
        if [[ ${H_arrayL[i]} -eq $targetH ]]; then
            targetindex=$(( i - 1 ))
            targetindex=$(( targetindex * 1000 ))
            targetindex=$(( targetindex / 180 ))
            targetindex=$(( targetindex * 100 ))
            targetindex=$(( targetindex / 1000 ))
            targetindex=$(( targetindex + 1 ))
        fi
    done

echo "$targetindex"


}



convertedH2=$(hconverter)


#uncomment if you want to use a custom starting hue
#convertedH=$custom_start_hue


#S and L math too hard, brute forcing it
testS=0
magickS=0

until [[ $magickS -eq $targetS ]]
do
    magick colortest/msblue.png -set option:modulate:colorspace hsl -modulate 100,$testS,$convertedH colortest/msnotblue.png
    msnotblue=$(magick colortest/msnotblue.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickH magickS magickL < <(converter_tester)
    ((testS++))
      
done

convertedS=$testS

testSb=0
magickSb=0

until [[ $magickSb -eq $targetS ]]
do
    magick colortest/sidebar-backdrop.png -set option:modulate:colorspace hsl -modulate 100,$testSb,$convertedH2 colortest/newsidebar-backdrop.png
    msnotblue=$(magick colortest/newsidebar-backdrop.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickHb magickSb magickLb < <(converter_tester)
    ((testSb++))
     
done

convertedSb=$testSb



testL=0
magickL=0

until [[ $magickL -eq $targetL ]]
do
    magick colortest/msblue.png -set option:modulate:colorspace hsl -modulate $testL,$convertedS,$convertedH2 colortest/msnotblue.png
    msnotblue=$(magick colortest/msnotblue.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickH magickS magickL < <(converter_tester)
    ((testL++))  
done


convertedL=$testL

testLb=0
magickLb=0

until [[ $magickLb -eq $targetL ]]
do
    magick colortest/sidebar-backdrop.png -set option:modulate:colorspace hsl -modulate $testLb,$converedSb,$convertedH2 colortest/newsidebar-backdrop.png
    msnotblue=$(magick colortest/newsidebar-backdrop.png -scale 1x1! -format "%[hex:u.p]\n" info:)
    read magickHb magickSb magickLb < <(converter_tester)
    ((testLb++))
      
done

convertedLb=$testLb

echo ""
echo -e "${GREEN}Color match found!${NC}"


#shifting the images to the desire color

echo -e "${GREEN}Converting images to desired primary color${NC}"




for f in custom-themes/$ThemeName/gtk-2.0/assets/*.png
    do
        magick $f -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH $f
    done



    for f in custom-themes/$ThemeName/gtk-3.0/assets/*.png
        do
            magick "$f" -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH "$f"
        done

    cp RedmondXP/gtk-3.0/assets/sidebar-backdrop.png custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png
       magick custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png -set option:modulate:colorspace hsl -modulate $convertedLb,$convertedSb,$convertedH2 custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png
                
    magick custom-themes/$ThemeName/gtk-3.0/assets/tray.png -set option:modulate:colorspace hsl -modulate 90,100,100 custom-themes/$ThemeName/gtk-3.0/assets/tray.png



    for f in custom-themes/$ThemeName/gtk-3.0/assets/*.xpm
        do
            magick "$f" -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH "$f"
        done
echo " 
########################################################################################
"

echo -e "${GREEN}Would you like to use greyscale minimize and maximize buttons?${NC}"
echo -e "${BLUE} Enter answer: (y/n)${NC}"
read darkprimary

echo " 
########################################################################################
"    
    if [[ ${darkprimary} == y ]]; then 
        grayscale_files=(
        "hide-active.xpm"
        "hide-inactive.xpm"
        "hide-prelight.xpm"
        "hide-pressed.xpm"
        "maximize-active.xpm"
        "maximize-inactive.xpm"
        "maximize-prelight.xpm"
        "maximize-pressed.xpm"
        "title_button.xpm"
        "title_button-border.xpm"
    )

    for file in "${grayscale_files[@]}"; do
        xpm_file="custom-themes/$ThemeName/gtk-3.0/assets/$file"
        if [[ -f "$xpm_file" ]]; then
            tmp="${xpm_file%.xpm}.png"
            magick "$xpm_file" "$tmp"
            magick "$tmp" -colorspace Gray -contrast-stretch 2%x2% "$tmp"
            magick "$tmp" "$xpm_file"
            rm -f "$tmp"
            
        fi
    done

    elif [[ ${darkprimary} == n ]]; then 
    echo ""
    fi

echo -e "${BLUE}Starting xfwm4${NC}"
    for f in custom-themes/$ThemeName/xfwm4/*.xpm
        do
            magick "$f" -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH "$f"
        done
    if [[ ${darkprimary} == y ]]; then
        for file in "${grayscale_files[@]}"; do
            xpm_file="custom-themes/$ThemeName/xfwm4/$file"
            if [[ -f "$xpm_file" ]]; then
                tmp="${xpm_file%.xpm}.png"
                magick "$xpm_file" "$tmp"
                magick "$tmp" -colorspace Gray -contrast-stretch 2%x2% "$tmp"
                magick "$tmp" "$xpm_file"
                rm -f "$tmp"
            fi
        done
    elif [[ ${darkprimary} == n ]]; then 
    echo ""
    fi

echo -e "${BLUE}Fixing menu buttons${NC}"
    for f in custom-themes/$ThemeName/menu_buttons/background/*.png
        do
            magick "$f" -set option:modulate:colorspace hsl -modulate $convertedL,$convertedS,$convertedH "$f"
        done


#merge menu buttons together
    magick custom-themes/$ThemeName/menu_buttons/background/start_active_a.png custom-themes/$ThemeName/menu_buttons/button/start_active_b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start_active.png
    magick custom-themes/$ThemeName/menu_buttons/background/start1-a.png custom-themes/$ThemeName/menu_buttons/button/start1-b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start1.png
    magick custom-themes/$ThemeName/menu_buttons/background/start-a.png custom-themes/$ThemeName/menu_buttons/button/start-b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start.png 
    magick custom-themes/$ThemeName/menu_buttons/background/start_active1_a.png custom-themes/$ThemeName/menu_buttons/button/start_active1_b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start_active1.png
    magick custom-themes/$ThemeName/menu_buttons/background/start_hover1_a.png custom-themes/$ThemeName/menu_buttons/button/start_hover1_b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start_hover1.png
    magick custom-themes/$ThemeName/menu_buttons/background/start_hover_a.png custom-themes/$ThemeName/menu_buttons/button/start_hover_b.png -layers flatten custom-themes/$ThemeName/menu_buttons/start_hover.png
    magick custom-themes/$ThemeName/menu_buttons/background/menu-box-a.png custom-themes/$ThemeName/menu_buttons/button/menu-box-b.png -layers flatten custom-themes/$ThemeName/menu_buttons/menu-box.png



    cp custom-themes/$ThemeName/menu_buttons/start_active.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/start_active1.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/start.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/start1.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/start_hover.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/start_hover1.png custom-themes/$ThemeName/gtk-3.0/assets/
    cp custom-themes/$ThemeName/menu_buttons/menu-box.png custom-themes/$ThemeName/gtk-3.0/assets/

    cp -r --update=none RedmondXP/* custom-themes/$ThemeName 
    cp -r custom-themes/$ThemeName ~/.themes/

echo -e "${BLUE}Image conversion complete${NC}"

#css editior
echo -e "${BLUE}Doing some initial CSS edits${NC}"


menubgavg=$(magick custom-themes/$ThemeName/gtk-3.0/assets/menubg.png -scale 1x1! -format "%[hex:u.p]\n" info:)

sed -i "s/PRIMRY/$primary/g" custom-themes/$ThemeName/gtk-3.0/gtk.css
sed -i "s/SECNDR/$secondary/g" custom-themes/$ThemeName/gtk-3.0/gtk.css
sed -i "s/MNUBGA/$menubgavg/g" custom-themes/$ThemeName/gtk-3.0/gtk.css
sed -i "s/25MNUB/$menubgavg/g" custom-themes/$ThemeName/gtk-3.0/gtk.css


cp -r custom-themes/$ThemeName ~/.themes/

echo " 
########################################################################################
"
echo -e "${GREEN} Now that our images are edited there there are a few colors that are in the CSS files that apply those images in your new custom theme. 


The theme has been moved to ~./themes/ so feel free to apply the theme, and consider your options while making these choices. When you do, you may notice some color inconsistencies, that is expected at this stage. 

Note: after choices have been made and the script finishes executing you may need to reload your theme${NC}"

echo " 
########################################################################################
"

echo -e "${GREEN}Given your primary color of #$primary enter your desired text color in hex values. 

(Recommended: black [000000] or white [FFFFFF] but you can test other options at https://webaim.org/resources/contrastchecker/ )${NC}"
echo ""
echo -e "${BLUE}Enter a hex color minus the starting #. Example: 000000${NC}" 
read textcolor

echo " 
########################################################################################
"
sed -i 's|@define-color custom_text_color #TXTCLR;|@define-color custom_text_color #'"$textcolor"';|g' "custom-themes/$ThemeName/gtk-3.0/gtk.css"

sed -i "s|TXTCLR|$textcolor|g" "custom-themes/$ThemeName/xfwm4/themerc"

echo ""
echo " 
########################################################################################
"
echo -e "${GREEN}When you highlight text, or an icon in your file browser would you either like to${NC} 

1. Make it a custom color (your secondary color)
2. Make it a custom color (your primary color)
3. Keep it the default windows light blue

${GREEN}Please note that this also effects buttons when they are pressed in. i.e. file/edit/view in your text editor.
${NC}"
echo " 
########################################################################################
"
echo "Enter a value (1 or 2 or 3)"
read highlightchoice

if [[ $highlightchoice == 1 ]]; then
    echo " 
########################################################################################
"
    echo -e "${GREEN}You have chosen to use a custom color for your highlight color. Given your secondary color of #$secondary, what would you like your text color to be? 

(Recommended: black [000000] or white [FFFFFF] but you can test other options at https://webaim.org/resources/contrastchecker/ )${NC}" 
    echo ""
    echo -e "${BLUE}Enter a hex color minus the starting #. Example: 000000${NC}"
    read hightc
    echo " 
########################################################################################
"
    sed -i "s/highlightchoice/$secondary/g" custom-themes/$ThemeName/gtk-3.0/gtk.css
    sed -i "s/highlighttext/$hightc/g" custom-themes/$ThemeName/gtk-3.0/gtk.css

elif [[ $highlightchoice == 2 ]]; then
    echo " 
########################################################################################
"
    echo -e "${GREEN}You have chosen to use your primary color for your highlight color. Given your primary color of $primary, what would you like your text color to be? 

(Recommended: black [000000] or white [FFFFFF] but you can test other options at https://webaim.org/resources/contrastchecker/ )" 
    echo ""
    echo -e "${BLUE}Enter a hex color minus the starting #. Example: 000000${NC}"
    read hightc
    echo " 
########################################################################################
"
    sed -i "s/highlightchoice/$primary/g" custom-themes/$ThemeName/gtk-3.0/gtk.css
    sed -i "s/highlighttext/$hightc/g" custom-themes/$ThemeName/gtk-3.0/gtk.css


elif [[ $highlightchoice == 3 ]]; then
    sed -i 's/highlightchoice/316ac5/g' custom-themes/$ThemeName/gtk-3.0/gtk.css
    sed -i 's/highlighttext/FFFFFF/g' custom-themes/$ThemeName/gtk-3.0/gtk.css

fi


cp -r custom-themes/$ThemeName ~/.themes/

echo " 
########################################################################################
"

echo -e "${Green}Your theme is ready and in your ~/.themes/ folder make sure to refresh your theme to see the final changes. If you want to change your primary or secondary color you can run the script again!${NC}"

echo ""
echo "Goodbye"

