# RedmondXP-Color-Customizer-for-XFCE
This is a script that was built out of a desire to use the RedmondXP theme, but replacing the WindowsXP blue with custom colors based off my background image instead. 

# **Setup**

### **Installation**
Open a terminal in your desired install directory and clone the repo via: 

```
git clone https://github.com/Bellatrix-Melody/RedmondXP-Color-Customizer-for-XFCE.git
```
Open a terminal in the repo folder (RedmondXP-Color-Customizer-for-XFCE-main/) and give the script executable permissions

```
sudo chmod +x redmond_color_converter.sh
```

### **Install Dependencies**

**Python3**: You can get this from your sofware manager or the repos
```
sudo apt install python3
sudo apt install python3-venv
```

**Image Magick**: I have included a script to install Image Magick that comes from this [repo](https://github.com/SoftCreatR/imei/blob/main/). Open a terminal in the repo folder (RedmondXP-Color-Customizer-for-XFCE-main/) and give it execute permissions via: 

```
sudo chmod +x magick_install.sh
```
Then run it:

```
sudo ./magick_install.sh
```
If you'd rather get this directly from Image Magick and not sudo a script from a github then you can find the standalone executable at: [https://imagemagick.org/script/download.php](https://imagemagick.org/script/download.php)

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

The script will guide you through the rest of the process. The setup question at the start just creates a virtual enviorment `venv` for the python script to run out of.

**What this script cannot do**

Change the text on the clock widget in the XFCE pannel. However you can do this manually by going to the clock settings and making a custom format using the follow code:

<img width="433" height="167" alt="image" src="https://github.com/user-attachments/assets/6d9c04f3-5b15-4e42-b50d-8f9904fceb53" />


```
<span color="#000000">%l:%M:%P</span>
```

In this example the custom text color is set to black.

## Tools

This repo comes with some other handy scripts for you to use or not, up to you. 

**Magick_HEX_to_HSL_converter**

A standalone version of the converter used in the main script that lets you start with a different base color. Useful for if you need to do batch processing of color conversion like this script does. For details on how to use this and how it works see the "How it works" section in this readme.

# **Examples**

A light bakground with color converted minimize and maximize buttons

<img width="2530" height="1308" alt="Screenshot_2025-11-18_12-25-38" src="https://github.com/user-attachments/assets/8d4d06c7-d8a3-4849-a066-b9d70d67a0d0" />

A dark background with greyscale minimize and maximize buttons

<img width="2530" height="1308" alt="image" src="https://github.com/user-attachments/assets/81534a07-832a-45ec-a671-48909a54b71d" />


# **How it works**

This will get a bit technical, so bear with me. 

The script consists of 3 main components

## **Finding the correct HSL for Image Magick**
It starts by taking a primary color (either chosen through the integrated python-based color extractor based off your chosen background image, or inputed by the user) and converting to HSL format. HSL is three components Hue, Saturation, and Lightness or in layman's terms base color, how much color, and how bright the color is (if you want to get really techincal check out the [wiki](https://en.wikipedia.org/wiki/HSL_and_HSV) )  

Image Magick does not take raw HSL colors for it's '-modulate' option so finding a color match is a bit tricky. 

I first created a color swatch that I created by using the following command: 

```
magick taskbar.png -scale 1x1! -format "%[hex:u.p]\n" info:
```   

This outputs the average color of taskbar.png (this is also reffered to as the pannel in XFCE) as a hex color. 

Example: 

```
recolor-target/gtk-3.0/assets$ magick taskbar.png -scale 1x1! -format "%[hex:u.p]\n" info:
265FD9FF
```
   

I then used GIMP to create a small image with just that averaged color (called msblue.png in the colortest/ folder).

I took this average and converted it to HSL colors and used this tool [here](https://r0d3r1ck0rd0n3z.github.io/ImageMagick-Modulate-Calculator/) with the H value of msblue.png. Using the math in the java script I was able to create a list of what custom H value in Image Magick will make the base color (from msblue.png) into the desired custom color. 

### **The brute force method**

Now here is where it gets a bit stupid. 

I could not find consistent math to convert standard saturation (0-100%) and standard lightness (0-100%) into Image Magick's saturation (0-200, 100 is no change) and lightness (0-200, 100 is no change) values. So I just have the script figure it out for me by brute forcing it. So the goal becomes finding the saturation and lightness values of our custom color. 

The brute force method is rather simple, we're going to '-modulate' our swatch, use the hue value we found in the previous section, and (starting at 0) test it until it matches the saturation value of our target color, and not touch the L vaule (for now). 

Note: Image Magick takes HSL values in the following way 

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

So to start we are setting two varriables testS and magickS to be equal to 0.

Then we have a loop saying until magickS is equal to targetS (the saturation level of our target custom color) do the following 4 commands:

Command 1:
  ```
magick colortest/msblue.png -set option:modulate:colorspace hsl -modulate 100,$testS,$convertedH colortest/msnotblue.png  
  ```

So here  set the lightness of our test swatch (msblue.png) to 100 (which in image magick means no change), set our saturation to the current value of targetS (0 to start), the hue value to our target hue value that we found above, and finally save it as msnotblue.png. 

Command 2:

  ```
msnotblue=$(magick colortest/msnotblue.png -scale 1x1! -format "%[hex:u.p]\n" info:)
```

Here we are saying that the varriable "msnotblue" is equal to the same command we ran earlier to find the average color of an image in hex format but on the image we just created i.e. msnotblue.png. 

Since we are testing the HSL value and not a hex value we need to convert the output of that command to an HSL format which is why we store it in a varriable, so that we can do with this:

Command 3:
  ```
read magickH magickS magickL < <(converter_tester)
``` 

This just sets the varriables magickH magickS and magickL to the output of the function much earlier in the script that converts hex colors to HSL values(see credits). The function converter-tester just tests the varriable msnotblue. 

Finally we have:

Command 4:

```
((testS++))
```  

This just increments the value of testS by 1 (so it testS is equal to 0 it adds one to it making it 1) until the condition of the loop is met i.e. the saturation level of msnotblue.png is the value of our custom color. 

Once the loop is over we store the value of testS in a varriable to use later.

We do this same thing again but looking for the lightness value until we have a set of L,S, and H values that will cause the desired color shift with Image Magick. 


## **Image Conversion**

Now that we have our target colors we just run our corrected magick command on all of the images in recolor-target, i.e. all of the blue things.

There are a couple notable extra things here, I use these commands to reprocess sidebar-backdrop.png (this is your sidebar in things like your file manager). I found that it was getting blown out in lighter color schemes, so I also run a bruteforce conversion on it earlier in the script:

Line 489:
```
cp RedmondXP/gtk-3.0/assets/sidebar-backdrop.png custom-themes/
$ThemeName/gtk-3.0/assets/sidebar-backdrop.png
magick custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png -set option:modulate:colorspace hsl -modulate $convertedLb,$convertedSb,$convertedH2 custom-themes/$ThemeName/gtk-3.0/assets/sidebar-backdrop.png  
```

I also take tray.png (the far right side of your pannel in XFCE) and lower the lightness value of it by ten. I found it was too samey and the slight adjustment after the color conversion makes it feel more seperated. 

Line 492:
   ```
magick custom-themes/$ThemeName/gtk-3.0/assets/tray.png -set option:modulate:colorspace hsl -modulate 90,100,100 custom-themes/$ThemeName/gtk-3.0/assets/tray.png
```
 
I also added an option to make the minimize and maximize buttons greyscale becasue I found they would get lost in darker color schemes. 

##Editing the CSS

So RedmondXP uses several CSS documents to assign the color of various elements and pulls them all into a primary CSS file called gtk.css in the gtk-3.0. I just set custom varriables to be called in the other documents, which you can see in gtk.css under the "custom colors" comment. The only files I touched are found in recolor-target/gtk-3.0/ so it should be easy to use something like  `grep -l varriablename *.css`  to see what I changed. The rest of the CSS files are unchanged. 

I also edit the file themerc in xfce/ since it determines the color of test in your title bar. 


# Credits

**RedmondXP**:[matthewmx86](https://github.com/matthewmx86/RedmondXP)

**color_extractor**: [Robinoscarsson](https://github.com/robinoscarsson/color_extractor)  

**the numbers for the hue conversion**: [r0d3r1ck0rd0n3z](https://github.com/r0d3r1ck0rd0n3z/ImageMagick-Modulate-Calculator/tree/master)

**Hex to HSL Coversion**: [z3rOR0ne](https://codeberg.org/z3rOR0ne/dyetide)


