These are the basic needed files and folders to build cocoLinux system.

### buildiso

buildiso is used to build a coco ISO.

#### Arguments

~~~
$ ./buildiso.sh -h
Usage: buildiso [options]
    -c                 Disable clean work dir
    -h                 This help
    -p <profile>       Buildset or profile [default: desktop]
    -v                 Verbose output to log file, show profile detail (-q)
~~~

* Uses the same signature that normal repo and has no mirrors package to install.

```bash
sudo pacman -Syy
```

### Install necessary packages:
```bash
sudo pacman -S archiso mkinitcpio-archiso git squashfs-tools grub --needed
```

### Clone:
```bash
git clone https://github.com/C0C0B01/coco-live.git coco-live-archiso
cd coco-live-archiso
```

### Build
```bash
sudo ./buildiso.sh -p desktop -v
```

As the result iso appears at the `out` folder
