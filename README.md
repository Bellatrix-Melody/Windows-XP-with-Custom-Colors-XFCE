# Windows-XP-with-Custom-Colors-XFCE

<img width="2530" height="1308" alt="image" src="https://github.com/user-attachments/assets/1e6ddc2b-3237-435b-ae73-ef766468cdbd" />

This is a script that was built out of a desire to use the RedmondXP theme, but replacing the Windows XP blue with custom colors based off my background image instead. I had done this by hand a couple[...]

# **Setup**

### **Installation**
Open a terminal in your desired install directory and clone the repo via: 

```
git clone https://github.com/Bellatrix-Melody/Windows-XP-with-Custom-Colors-XFCE.git

```
Open a terminal in the repo folder (RedmondXP-Color-Customizer-for-XFCE-main/) and give the script executable permissions

```
sudo chmod +x redmond_color_converter.sh
```

### **Install Dependencies**

**Python3**: You can get this from your software manager or the repos
```
sudo apt install python3
sudo apt install python3-venv
```

**ImageMagick**: I have included a script to install ImageMagick that comes from this [repo](https://github.com/SoftCreatR/imei/blob/main/). Open a terminal in the repo folder (RedmondXP-Color-Custo[...]

```
sudo chmod +x magick_install.sh
```
Then run it:

```
sudo ./magick_install.sh
```
If you'd rather get this directly from ImageMagick and not sudo a script from github then you can find the standalone executable at: [https://imagemagick.org/script/download.php](https://imagemagic[...]

Open a terminal in the download folder and give it executable permissions

```
sudo chmod +x magick
```
Then copy it into your /bin folder. 

# **Usage**

Place your desired background images in RedmondXP-Color-Customizer-for-XFCE-main/backgrounds/

Run the script: 

```
./redmond_color_converter.sh
```

The script will guide you through the rest of the process. The setup question at the start just creates a virtual environment `venv` for the python script to run out of.

**For the greyscale minimize and maximize button question**

I think saying yes is the safest bet here, because, depending on the color, they can either be totally blown out or invisible. 

**Known Bugs**

When using a custom font on the clock in the XFCE panel the text color does not change. If you run into this you can change it manually by going to the clock settings and making a custom format usin[...]

<img width="433" height="167" alt="image" src="https://github.com/user-attachments/assets/6d9c04f3-5b15-4e42-b50d-8f9904fceb53" />

```
<span color="#000000">%l:%M:%P</span>
```

In this example the custom text color is set to black.

## Included
**Fonts**

I include a pack of truetype fonts that make things more XP like which I got from [rozniak's](https://github.com/rozniak/xfce-winxp-tc) winxp total conversion. Just drop them wherever your distro keep[...]

### Tools
This repo comes with some other handy scripts beyond the color converter for you to use or not, up to you. They are in the tools folder

**Magick_HEX_to_HSL_converter**

A standalone version of the converter used in the main script that lets you start with a different base color. Useful for if you need to do batch processing of color conversion like this script does. [...]

**Custom Icon Swapper**

A pretty simple icon swapper using [B00merang's](https://github.com/B00merang-Artwork/Windows-XP) XP icon pack as a base. You need to first make the base icons you want to use 128x128 using a program [...]

**If you do not make the images you want to use as custom icons 128x128 you will have icon size issues!!**

All you need to do is replace the current files in custom-icons using the following format:

**Your custom "My Computer icon"**

computer.png

**Your custom "My Documents icon"**

documents.png

**Your custom "Network icon"**

network.png

**Your custom "Trash icon"**

trash.png

# **Examples**

**A light primary color with color converted minimize and maximize buttons**

<img width="2530" height="1308" alt="image" src="https://github.com/user-attachments/assets/009aae25-ff54-41f6-8e9f-3f60556f0036" />

**A vibrant primary color with greyscale minimize and maximize buttons and a secondary color system tray**

<img width="2530" height="1341" alt="image" src="https://github.com/user-attachments/assets/b30dac31-7a1c-4e90-9762-3d478950488d" />

**A dark primary color with greyscale minimize and maximize buttons and a secondary color system tray**

<img width="2530" height="1309" alt="image" src="https://github.com/user-attachments/assets/4814c787-116d-4f15-b72a-7646f3878a09" />

# **How it works**

This will get a bit technical, so bear with me. 

The script consists of 3 main components

## **Finding the correct HSL for ImageMagick**
It starts by taking a primary color (either chosen through the integrated python-based color extractor based off your chosen background image, or inputted by the user) and converting to HSL format. HSL[...]

ImageMagick does not take raw HSL colors for its '-modulate' option so finding a color match is a bit tricky. 

I first created a color swatch that I created by using the following command: 

```
magick taskbar.png -scale 1x1! -format "%[hex:u.p]\n" info:
```   

This outputs the average color of taskbar.png (this is also referred to as the panel in XFCE) as a hex color. 

Example: 

```
recolor-target/gtk-3.0/assets$ magick taskbar.png -scale 1x1! -format "%[hex:u.p]\n" info:
265FD9FF
```
   

I then used GIMP to create a small image with just that averaged color (called msblue.png in the colortest/ folder).

I took this average and converted it to HSL colors and used this tool [here](https://r0d3r1ck0rd0n3z.github.io/ImageMagick-Modulate-Calculator/) with the H value of msblue.png. Using the math in the j[...]

### **The brute-force method**

Now here is where it gets a bit stupid. 

I could not find consistent math to convert standard saturation (0-100%) and standard lightness (0-100%) into ImageMagick's saturation (0-200, 100 is no change) and lightness (0-200, 100 is no chan[...]

The brute-force method is rather simple, we're going to '-modulate' our swatch, use the hue value we found in the previous section, and (starting at 0) test it until it matches the saturation value [...]

Note: ImageMagick takes HSL values in the following way 

```
-modulate L,S,H
```

The code for this section looks like this: 

```
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
```

So to start we are setting two variables testS and magickS to be equal to 0.

Then we have a loop saying until magickS is equal to targetS (the saturation level of our target custom color) do the following 4 commands:

Command 1:
  ```
magick colortest/msblue.png -set option:modulate:colorspace hsl -modulate 100,$testS,$convertedH colortest/msnotblue.png  
  ```

So here we set the lightness of our test swatch (msblue.png) to 100 (which in ImageMagick means no change), set our saturation to the current value of testS (0 to start), the hue value to our target h[...]

Command 2:

  ```
msnotblue=$(magick colortest/msnotblue.png -scale 1x1! -format "%[hex:u.p]\n" info:)
```

Here we are saying that the variable "msnotblue" is equal to the same command we ran earlier to find the average color of an image in hex format but on the image we just created i.e. msnotblue.png. 

Since we are testing the HSL value and not a hex value we need to convert the output of that command to an HSL format which is why we store it in a variable, so that we can do with this:

Command 3:
  ```
read magickH magickS magickL < <(converter_tester)
``` 

This just sets the variables magickH magickS and magickL to the output of the function much earlier in the script that converts hex colors to HSL values(see credits). The function converter_tester ju[...]

Finally we have:

Command 4:

```
((testS++))
```  

This just increments the value of testS by 1 (so if testS is equal to 0 it adds one to it making it 1) until the condition of the loop is met i.e. the saturation level of msnotblue.png is the value o[...]

Once the loop is over we store the value of testS in a variable to use later.

We do this same thing again but looking for the lightness value until we have a set of L, S, and H values that will cause the desired color shift with ImageMagick. 

## **Image Conversion**

Now that we have our target colors we just run our corrected magick command on all of the images in recolor-target, i.e. all of the blue things.

There are a couple notable extra things here, I use these commands to reprocess sidebar-backdrop.png (this is your sidebar in things like your file manager). I found that it was getting blown out in l[...]

Line 489:
```
cp RedmondXP/gtk-3.0/assets/sidebar-backdrop.png custom-themes/
$ThemeName/gtk-3.0/assets/sidebar-backdrop.png
magick custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png -set option:modulate:colorspace hsl -modulate $convertedLb,$convertedSb,$convertedH2 custom-themes/$ThemeName/gtk-3.0/assets/sidebar[...]
```

I also take tray.png (the far right side of your panel in XFCE) and lower the lightness value of it by ten. I found it was too samey and the slight adjustment after the color conversion makes it feel[...]

Line 492:
   ```
   magick "$tmp" -set option:modulate:colorspace hsl -modulate 100,0,100 "$tmp"
```
 
I also added an option to make the minimize and maximize buttons greyscale because I found they would get lost in darker color schemes. I'm just taking the base RedmondXP images and completely desatur[...]

## Editing the CSS

So RedmondXP uses several CSS documents to assign the color of various elements and pulls them all into a primary CSS file called gtk.css in gtk-3.0. I just set custom variables to be called in t[...]

I also edit the file themerc in xfce/ since it determines the color of text in your title bar. 

# Credits

**RedmondXP** 

[matthewmx86](https://github.com/matthewmx86/RedmondXP)

**Fonts**

[rozniak](https://github.com/rozniak/xfce-winxp-tc)

**Icons for the icon swapper**

[B00merang](https://github.com/B00merang-Artwork/Windows-XP)

**color_extractor**

[Robinoscarsson](https://github.com/robinoscarsson/color_extractor)  

**the numbers for the hue conversion**

[r0d3r1ck0rd0n3z](https://github.com/r0d3r1ck0rd0n3z/ImageMagick-Modulate-Calculator/tree/master)

**Hex to HSL Conversion**

[z3rOR0ne](https://codeberg.org/z3rOR0ne/dyetide)
