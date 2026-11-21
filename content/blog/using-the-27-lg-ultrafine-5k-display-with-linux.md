+++
title = "Using the 27\" LG UltraFine 5k Display with Linux"
description = "Getting the LG UltraFine 5K display working reliably with Linux, including Thunderbolt AIC compatibility notes."
slug = "using-the-27-lg-ultrafine-5k-display-with-linux"
date = 2023-12-07

[extra]
cover = "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&q=80"

+++

<section class="updates">

**UPDATE 2019-07-25:**

Following some comments on the original post below, I replaced the Asus ThunderboltEX 2 AIC with a Gigabyte GC-Titan Ridge Thunderbolt AIC, which has two DisplayPort inputs. The monitor now runs at its full 5K resolution, and X11, GDM, and Gnome detected the correct settings without help. For the autodetection to take effect I had to remove `/etc/X11/xorg.conf`, `$HOME/.config/monitors.xml`, and `/var/lib/gdm3/.config/monitors.xml`.

</section>

<section class="updates">

**UPDATE 2019-07-26:**

With the GC-Titan Ridge card installed, the computer stopped recognizing the USB devices in the monitor (the speaker and microphone). With the previous card I hadn't turned on any of the Discrete Thunderbolt Support options in the BIOS, and everything had worked. This card needs some BIOS settings.

I found [these directions for setting up TB3 in the Asus Prime Z390-A BIOS](https://www.technopat.net/konu/success-prime-z390-a-9900k-thunderbolt-3-macos-10-14.651013). The author was configuring the BIOS for a Hackintosh build, but I copied the settings anyway, apart from the Windows 10 Thunderbolt Support option. When I tried to set that to the specified value, the BIOS utility froze.

After those changes, the monitor's USB audio was detected at startup.

</section>

The 27" LG UltraFine 5K display accepts video only through Thunderbolt, so out of the box it works with recent MacBooks and with little else. I bought one for my MacBook without noticing that. A year later I wanted to use it with a desktop PC running Linux, and found very little written about how. It can be done. With the first Thunderbolt card I tried, it took hours of trial and error and three hand-written configuration files, and the display ran below its full resolution. With a different card, described in the updates above, it runs at full 5K with no configuration. Anyone starting now should begin with that second card. The rest of this post records the original setup.

Lachlan and I built the PC over a weekend. I hadn't built one in about fifteen years. Over the previous couple of years, Apple's choices with macOS had made it more and more annoying for the kind of software development I do, and I'd wanted to go back to Linux, which I used first. I had also wanted to build a computer with Lachlan for a while, since he's the one of my kids who is really into technology. I brought the experience of handling the parts safely and debugging what went wrong. Lachlan knew what hardware is available now, and his advice on the processor, motherboard, and video card was good.

The monitor was the one difficult part of the build. It's a beautiful display, and it was expensive. Some research turned up hints that it could work with a PC whose motherboard has a Thunderbolt header, given a Thunderbolt add-in card (AIC) with a mini-DisplayPort input. A patch cable carries the DisplayPort output of the video card into the AIC's mini-DisplayPort input, and the AIC sends the video signal out through its Thunderbolt port. There wasn't much information about this arrangement, and less about Linux support for it.

We decided to try. We chose the rest of the system with that constraint in mind, but the AIC cost only about $35 (USD), and the system would be a good one regardless. If it failed, I'd sell the LG and buy a monitor with ordinary DisplayPort inputs, which would have been a hassle and no worse.

It worked, after a lot of trial and error. The rest of the hardware worked without any effort, with one exception: there are no Linux drivers for the Asus Aura RGB lighting. That's an aesthetic complaint, though an annoying one, because the slowly flashing red glow on the video card can't be turned off.

Here is the parts list for the build:

* CPU: Intel Core i9-9900k 5.0 GHz
* CPU Cooler: Noctua NH-D15 82.5 CFM CPU Cooler
* Motherboard: Asus Prime Z390-A ATX LGA1151
* Memory: Corsair Vengeance LPX 16 GB (2 x 8 GB) DDR4-3000
* Storage: Samsung 970 Evo 250 GB M.2-2280 Solid State Drive
* Video Card: Asus GeForce GTX 1070 8 GB STRIX Video Card
* Case: Corsair 760T Black ATX Full Tower Case
* Power Supply: EVGA SuperNOVA G2 650 W 80+ Gold Cerified Fully-Modular ATX
* Wireless Adapter: Gigbyte GC-WB867D-I PCI-Express x1 802.11a/b/g/n/ac WiFi
    Adapter
* Thunderbolt AIC: Asus ThunderboltEX 3
* Operating System: Ubuntu Linux 18.10

## Installing the Nvidia driver

With the Nvidia card's DisplayPort output running into the Thunderbolt AIC and the monitor connected by its Thunderbolt cable, a fresh install of Ubuntu started normally and we could log in to the Gnome 3 desktop. Nvidia doesn't publish open-source drivers for Linux, and Ubuntu doesn't install the closed-source ones by default, so what you get is the open-source nouveau driver. It handles most things. To use what the card can do, we needed Nvidia's proprietary driver.

Ubuntu's apt repository has the `nvidia-driver-390` package, and `ubuntu-drivers autoinstall` will switch to it. The distribution lags behind Nvidia's releases, though, which were at version 415 when I wrote this. For the latest drivers, add the PPA and update apt:

```
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update
```

Then install the proprietary driver:

```
sudo apt install nvidia-driver-415 # or whatever the latest version is
```

This adds the kernel module and some configuration. After the reboot that follows, the desktop manager doesn't load. You get a blank screen, perhaps with a blinking cursor.

## Getting the display to come up

We had another display in the house with an HDMI input, so we connected it and rebooted. GDM loaded on the HDMI display. I reattached the LG as a second monitor. Nothing appeared on it, but Gnome's display settings listed it as a monitor.

On a whim I changed the LG's resolution from "auto" to 4096x2304, and it started working. I don't know the cause for certain. My guess is that passing the signal through the Thunderbolt AIC makes automatic detection of the resolution fail.

That wasn't the end of it. The debugging that followed was trial and error, searching, and piecing together reports from people with similar symptoms, none of whom had this combination of hardware. The solution was to configure the display explicitly in all three of Xorg, GDM, and Gnome. These are the files that had to change. With different hardware you may need to adjust them.

In `/etc/X11/xorg.conf`:

```
# nvidia-settings: X configuration file generated by nvidia-settings
# nvidia-settings:  version 415.27


Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
    Option         "Xinerama" "0"
EndSection

Section "Files"
EndSection

Section "Module"
    Load           "dbe"
    Load           "extmod"
    Load           "type1"
    Load           "freetype"
    Load           "glx"
EndSection

Section "InputDevice"

    # generated from default
    Identifier     "Mouse0"
    Driver         "mouse"
    Option         "Protocol" "auto"
    Option         "Device" "/dev/psaux"
    Option         "Emulate3Buttons" "no"
    Option         "ZAxisMapping" "4 5"
EndSection

Section "InputDevice"

    # generated from default
    Identifier     "Keyboard0"
    Driver         "kbd"
EndSection

Section "Monitor"

    # HorizSync source: edid, VertRefresh source: edid
    Identifier     "Monitor0"
    VendorName     "Unknown"
    ModelName      "LG Electronics LG UltraFine"
    HorizSync       31.5 - 177.7
    VertRefresh     60.0 - 60.0
    Option         "DPMS"
EndSection

Section "Device"
    Identifier     "Device0"
    Driver         "nvidia"
    VendorName     "NVIDIA Corporation"
    BoardName      "GeForce GTX 1070"
EndSection

Section "Screen"

# Removed Option "metamodes" "DP-0: nvidia-auto-select +0+0"
    Identifier     "Screen0"
    Device         "Device0"
    Monitor        "Monitor0"
    DefaultDepth    24
    Option         "Stereo" "0"
    Option         "nvidiaXineramaInfoOrder" "DFP-3"
    Option         "ConnectedMonitor" "DP-0"
    Option         "metamodes" "DP-0: 4096x2304 +0+0"
    Option         "SLI" "Off"
    Option         "MultiGPU" "Off"
    Option         "BaseMosaic" "off"
    SubSection     "Display"
        Depth       24
    EndSubSection
EndSection
```

In both `$HOME/.config/monitors.xml` and `/var/lib/gdm3/.config/monitors.xml` (my guess is that the value of `<serial>` has to be changed to the serial number of your own monitor):

```xml
<monitors version="2">
  <configuration>
    <logicalmonitor>
      <x>0</x>
      <y>0</y>
      <scale>1</scale>
      <primary>yes</primary>
      <monitor>
        <monitorspec>
          <connector>DP-0</connector>
          <vendor>GSM</vendor>
          <product>LG UltraFine</product>
          <serial>707NTFA2N827</serial>
        </monitorspec>
        <mode>
          <width>4096</width>
          <height>2304</height>
          <rate>59.999275207519531</rate>
        </mode>
      </monitor>
    </logicalmonitor>
  </configuration>
</monitors>
```

With those files in place, neither X nor Gnome relies on autoconfiguration of the display, and the LG works. It isn't running at 5K in this setup, but it still looks great.
