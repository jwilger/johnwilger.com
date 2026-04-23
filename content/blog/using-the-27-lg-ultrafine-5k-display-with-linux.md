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

Based on some comments made on the original post below, I swapped out the Asus ThunderboltEX 2 AIC
for a Gigabyte GC-Titan Ridge Thunderbolt AIC that supports two DisplayPort inputs. I'm happy to
report that I can now use the monitor in full 5k resolution *and* that X11, GDM, and Gnome were
able to autodetect all of the correct settings (after removing the `/etc/X11/xorg.conf`,
`$HOME/.config/monitors.xml`, and `/var/lib/gdm3/.config/monitors.xml` files in order to get the
autodetection to kick in.)

</section>

<section class="updates">

**UPDATE 2019-07-26:**

Interestingly, the computer stopped recognizing the USB devices (speaker and microphone) in the
monitor with the new, GC-Titan Ridge TB3 AIC installed. With the previous AIC, I did not
specifically turn on any of the Discrete Thunderbolt Support options in the BIOS and everything
was working fine. It would seem, however, that this AIC requires some BIOS settings to get
everything working.

I found [these directions for setting up TB3 in the Asus Prime Z390-A
BIOS](https://www.technopat.net/konu/success-prime-z390-a-9900k-thunderbolt-3-macos-10-14.651013).
In this case, the author was attempting to configure the BIOS for a Hackintosh build, but I
cargo-culted the setup anyway with the exception of setting the Windows 10 Thunderbolt Support
(when I attempted to set that to the specified value, the BIOS utility just froze up completely.)

After changing those BIOS settings, the USB audio in the monitor was detected just fine on
startup.

</section>

Lachlan and I built a new desktop PC this past weekend (something I haven't done
in probably 15 years). Over the past couple of years, I've grown more and more
annoyed with some of the choices Apple has been making with MacOS that have made
it more annoying to use the system for the kind of software development I do,
and I've had an itch to return to my first love: Linux. I've also wanted to
share that experience of building up a computer with Lachlan for a while, since
he's the one of my kids who is really into all things technology. To be honest,
while I brought the knowledge and experience of how to safely handle the
equipment and debug any issues, Lachlan was the one who brought the knowledge of
what technology is available today and was able to give great advice in terms of
picking out the processor, motherboard, and video card.

We had one particular challenge, though, in building this system. Last year, I
bought one of the new 27" LG UltraFine 5k displays to use with my Macbook. It's
truly a beautiful display in terms of picture quality, and...well...it was
pretty darned expensive, too. What I stupidly didn't realize at the time is that
it *only* has a Thunderbolt input and would pretty much only work "out of the
box" with the newest Macbooks. D'oh!

A little research showed hints of being able to get the LG 5k monitor to work
with a PC if you have a motherboard that provides a Thunderbolt header *and* you
install a special Thunderbolt AIC (add-in card) that has a mini-DisplayPort
input. The idea is that you use a patch cable to feed the DisplayPort output
from your video card into the Thunderbolt AIC's mini-DisplayPort input, and then
the AIC will send the video signal through its Thunderbolt output. Unfortunately
there was not a huge amount of information out there about this particular
setup, particularly with regard to Linux support.

We decided to go ahead and try to get it working. While we spec'ed out the
system with that as a central constraint, the AIC itself only cost around $35.00
(USD), and the rest of the system would still be great aside from that. If it
didn't work out, the worst case was that I'd sell the LG 5k monitor and buy a
new monitor with regular DisplayPort inputs—a hassle, but not a disaster.

I'm happy to report that we *did* get the monitor working great with Linux after
a lot of trial and error (see below for the details about configuring Linux to
work with this setup) and all of the other hardware worked well out of the box
(except for the lack of any Linux drivers for all of the Asus Aura RGB stuff,
which is only an aesthetic complaint—although an annoying one, because there is
no way to turn off the slowly flashing red glow on the video card).

Here is the part-list for the build:

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

After building the system with this configuration, running the Nvidia's DP
output into the Thunderbolt AIC, and connecting the LG 5k monitor via its
Thunderbolt cable, a fresh install of Ubuntu loaded up fine, and we were able to
log into the Gnome 3 desktop just fine. Unfortunately (or perhaps fortunately in
this case?), Nvidia does not provide their own open-source drivers for Linux,
and Ubuntu does not install the closed-source drivers by default. Instead, you
get the open-source nouveau driver. That driver works fine for most things, but
if we wanted to settle for "most things", we'd just have used the on-board GPU
of the motherboard. In order to take advantage of the Nvidia's capabilities, we
needed to install the proprietary Nvidia drivers. Ubuntu's apt repository
contains the `nvidia-driver-390` package, and they even make it easy to switch
to it by running `ubuntu-drivers autoinstall`, however the distribution lags
behind the official release of the drivers, which are up to version 415 as of
this writing. In order to have access to the latest drivers, just add the PPA
and update apt:

```
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update
```

Then you can install the proprietary driver with:

```
sudo apt install nvidia-driver-415 # or whatever the latest version is
```

This will add the appropriate kernel module and some necessary configuration.

Then you'll reboot your computer, and...

The desktop manager won't load. You'll probably be staring at a blank screen,
perhaps with a blinking cursor.

Luckily, I do have another display here at the house that has an HDMI input, so
we were able to hook that display up for some debugging. We hooked up the other
display and rebooted. This time, GDM loaded up on the HDMI display just fine. I
then reattached the LG display as a second monitor. Nothing showed up on it,
*but*, it showed up as a monitor in Gnome's display settings. Heh. That's
weird...

On a whim, I changed the resolution of the LG display from "auto" to 4096x2304,
and..._all of the sudden it worked!_

I don't know for sure, but my guess is that something about being passed through
the Thunderbolt AIC is causing the automatic detection of the resolution to
fail.

Great, we're done now, right?

Not exactly. I'll spare you the details of the rest of the debugging we went
through (*lot's* of trial and error, searching Google, and piecing together what
I could find from people who had sort-of-kind-of similar symptoms here and
there, but never all in the same combination, and definitely never with this set
of hardware.) Suffice it to say that the solution lies in being *very* specific
about configuring the display with all three of Xorg, GDM, and Gnome. Here are
the contents of the configuration files that needed to be changed in order to
get this working on the new system (you may need to tweak them a bit if you have
a different combination of hardware, but hopefully this saves you from the hours
of trial and error!):

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

In *both* `$HOME/.config/monitors.xml` *and*
`/var/lib/gdm3/.config/monitors.xml` (my guess is that you'll need to change the
value for `<serial>` here to the serial number for your actual monitor):

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

With those files in place, neither X nor Gnome were relying on autoconfiguration
of the display's settings, and the LG 5k display seems to be working just fine
(although not actually at "5k", but it still looks great.)
