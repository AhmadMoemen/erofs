# OPlus image utilities #

### Prerequisites ###
- JDK 8+
- Linux running kernel 5.4 or up (check with `uname -r`)
- I suggest not to use WSL as it has disabled SELinux and doesn't have erofs support by default.

### OPlus rebuild script ###
- (NEW!) This runs all needed scripts for oplus image conversion and merging.
Usage:
`
sudo ./oplus-rebuild.sh <firmware zip> <arguments>
`
By default this program converts system, system_ext and vendor to ext4 and merges my_* to system.
`--gsi`: convert only system to ext4 and merge all partitions to system except vendor.
`--oplus`: convert all my_* images to ext4.
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

### OPlus custom partition merging ###
- The script will automatically merge the my_* partitions into system.

Usage:
`
sudo ./oplus-merge.sh <arguments>
`
`--gsi`: convert only system to ext4 and merge all partitions to system except vendor.
`--oplus`: convert all my_* images to ext4.

### Notes ###
- For now you have to specify payload or zip filename, will remove that requirement later...
- Make sure you have enough space. (probably like 27gb recommended)

### To-Do ###
- Remove dependency of system file_contexts to build all images (we currently cat system filecontexts to the working file contexts to make the image resign properly)
- Run checks on mounting image(*) (It is reported by [Velosh](https://github.com/velosh) that sometimes mounting erofs images without `-o loop -t erofs` does not work. However it works on my PC, that's why I introduced [this commit](https://github.com/JamieHoSzeYui/oplus-utils/commit/d6b9b3621847117ca60691bd3749d9107f10c1b3). Will work on checks for it later.)

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
