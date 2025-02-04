# OPlus image utilities #

### Prerequisites ###
- JDK 8+
- Linux running kernel 5.4 or up (check with `uname -r`)
- I suggest not to use WSL as it has disabled SELinux and doesn't have erofs support by default.

### OPlus rebuild script ###
- (NEW!) This runs all needed scripts for oplus image conversion and merging.
Usage:
`
sudo ./oplus-rebuild.sh
`
### Image rebuilding ###
- Used to rebuild read-only erofs images into EXT4 mountable images.
Usage:
` 
sudo ./erofs.sh <path to original image> <image partition name>
`
For example, if I'm trying to make system_ext image ext4, I'll use the following command:
`
sudo ./erofs.sh system_ext.img system_ext
`

- IF you're running into issues like "not enough space to setup filesystem", specify filesystem size by adding the size (I recommend 64MB) after $2.

### Product image rebuilding ###
- OPlus (previously oppo) has been a jerk lately and keeps adding a butt ton of useless so-called "optimizations" (porting killers). This is one of them.
- In oplus Android 12 builds, OPlus has added `OPLUS_FEATURE_OVERLAY_MOUNT` to "mount product partition from existing my_* partitions" (to save image space? idk). With this going on, the product image shipped with OTAs is a dummy image that could not be mounted.
- Non-OPlus devices does NOT have `OPLUS_FEATURE_OVERLAY_MOUNT` implementation (and it is highly unrecommended to use it, as someone has bricked their devices before after implementing it). However, product image should NOT be empty (there is a system symlink pointing to `/product`). Therefore, this script is written to merge the my_* partitions into a single product image to replicate the `/product` behavior on OPlus devices.
- Note: The product partition might NOT be a dummy image, but might be a generic one, it has the device props!
Not sure about the implementation at all but it seems like product image can be fixed to be mounted after all...

Usage:
`
sudo ./product-merge.sh
`

### OPlus custom partition merging ###
- We will still have to merge my_* partitions after building the product image (as not all files exist in product image). The script will automatically merge the my_* partitions into system.

Usage:
`
sudo ./oplus-merge.sh
`

### Notes ###
- All images (especially system) must be the dir that the script is ran.
- Make sure you have enough space. (probably like 27gb recommended)

### To-Do ###
- Remove dependency of system file_contexts to build all images (we currently cat system filecontexts to the working file contexts to make the image resign properly)
- Run checks on mounting image(*) (It is reported by [Velosh](https://github.com/velosh) that sometimes mounting erofs images without `-o loop -t erofs` does not work. However it works on my PC, that's why I introduced [this commit](https://github.com/JamieHoSzeYui/oplus-utils/commit/d6b9b3621847117ca60691bd3749d9107f10c1b3). Will work on checks for it later.)
- Make an argument for `oplus-merge` to either merge some odm files to system or create a separate odm image.

*: Regarding checks, when I mount an image with auto type but I never mounted with erofs type it won't be mounted, after trying `-t erofs` then mounting with `t- auto` the auto mounting works fine with erofs images, so I had to add a testmount method in erofs script, hit me up in the issues if your problem isn't resolved, in my case it did.

### Credits and Thanks ###

[Amack](https://github.com/amackpro)

[Erfan Abdi](https://github.com/erfanoabdi)

[Velosh](https://github.com/velosh)

[Piraterex](https://github.com/piraterex)

[PatrickFav](https://github.com/patrickfav)

[Rain2Wood](https://github.com/rain2wood)

[Xiaoxindada](https://github.com/xiaoxindada)

And all those I forgot to mention.
