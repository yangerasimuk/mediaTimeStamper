# mediaTimestamper
Console application for macOS with only one function - bulk rename photo/video files to more unique names using timestamp from file attributes or EXIF metadata for photo.

## Story

I love to take pictures, and everybody in my family use camera to save all interesting for family history. 
In total we have DSLR, three telephones and two tablets.

For everty event I manually create new folder, and download photo from all sources. I like to look at the event from all sides, through all lens.

Everything was fine, until the moment, when I rewrite photo on disk by new one. This photos have same name, but different content.
I thought for a problem, got user experience of other people and decided to add timestamp to the name, as following:

DSC_2987.JPG -> 2017-01-20_21-40-15_DSC_2987.JPG

This way of organizing I liked. Besides unique names, now any file manager automatically sort photos, so I can view photos from different sources into a single time stream.

Look at these 2 lists, which will be mor usefull:

* DSC_2987.JPG
* DSC_2988.JPG
* DSC_2989.JPG
* DSC_2990.JPG
* IMG_0182.JPG
* IMG_0183.JPG
* IMG_0184.JPG

or

* 2017-01-20_18-33-30_IMG_0182.JPG
* 2017-01-20_21-40-15_DSC_2987.JPG
* 2017-01-20_21-45-25_DSC_2988.JPG
* 2017-01-20_21-46-55_DSC_2989.JPG
* 2017-01-20_22-05-13_IMG_0183.JPG
* 2017-01-20_22-06-47_IMG_0184.JPG

You will say that any file manager can sort by creation/modification date. But in real world file attributes rewrited during move from/to net storages or updates by some noisy programms. Right know I look hundred photos with Creation date = 2000-01-01 00:00:00.

I usually rename files using one of the professional photo tool, as long as not noticed that the application does 
not rename video files and special dependent on the photo files, such as, .AAE (filters, effects). 
I look for more friendly app, but found only a paid programs, so I write own.

## Decision

So, there is a problem - non-unique naming for photo files. The optimal solution to this problem seems to add to the original file name, an unique value - timestamp from Creation date. Most modern cameras store information about creating photo in EXIF. If this metadata will be unavailible, Creation date well be get from file attributes.

## Setup
mediaTimestamper - console program for MacOS, processing files in the current folder. To make it work in any folder, 
you must either put it in photo directory itself, or place it in one of the public folders, for example, /usr/local/bin. 
When you build a program from XCode, executable file will be automatically copied to the /usr/local/bin.

## How to launch?

To run the program, open the console (Terminal), change current directory to yours, contains photo, type mtstamper and press [Enter].

### Command line

mtstamper - the program will start with the default settings (output only the statistics, the source files will be deleted)

mtstamper -i --info or - print info about processed files,

mtstamper -t or --test - source files will be saved,

mtstamper -it or --info --test - print info about processed files and source files will be saved.

### Performance
You know, it's difficult to say how quickly the program will process your mass data. In better way I'm give statistic of test launches on my data:

1. Photo: 1000, 2,5Gb. MacBook Pro with SSD. Time: 1 minute.
2. Photo: 800, 3,5Gb. MacBook Pro with SSD. Time: 2 minutes.
3. Photo: 4600, 6Gb. MacBook Pro with SSD. Time: 3 minutes.
4. Photo: 1800, 6Gb. Macbook Pro with SSD and flash card SanDisk 64Gb/SDXC/10/3. Time: 18 minutes.

### Processed files
Program rename files with source names and following extensions: photo (.jpeg, .jpg, .png, .gif), video (.mov, .mpeg, .mp4, .avi) and depend (.aae, .ytags). Nothing else will not be processed.

gl hf

Yan Gerasimuk

February 8, 2017
