# Slab

A NixOS module (collection of packages and configuration) that can be
installed on a phone to provide a responsive and usable experience

That's the plan.

Right now - it might be responsive, but it's not very usable


> A drug used by Trolls, consisting of ammonium chloride cut with
> radium. [...] The actual effects of Slab are similar to LSD, with
> the troll in question seeing things for a prolonged period, not
> causing any trouble, and just wandering off to look at the pretty
> pictures. While the troll will usually go find somewhere quiet to
> enjoy the show, it has nasty side effects up to and including
> melting a troll's brain.

- https://wiki.lspace.org/Slab


## TODO/BUGS

"everything"

* need a key/pin lock of some kind (swaylock doesn't open onscreen
  keyboard so can't use it)

* keyboard
  - arrow keys are half-size
  - ctrl key is sticky (https://github.com/valderman/squeekboard-sway/commit/0ae1313659d4d7569169c75c5363a18580497e17 is a clue)
  - layout files must be hand-copied into ~/.local/share/

* add pane-aware gestures so apps can be dismissed/hidden by dragging
them offscreen. This could be a chunk of work: libinput doesn't and
won't support touchscreen gestures, lisgd sees the same events as the
compositor (doesn't consume them when it recognises a gesture)

  - something in the way we start lisgd seems to spawn many many processes

* switch termite for something still maintained (alacritty?)

* don't let sway suspend the device without warning when ssh sessions active
   sudo -b systemd-inhibit --mode=block --why="SSH session" sleep 300

* improve networkmanager ui to work with touch input (nmtui not quite it)

* mobile network

* sort out sleep
 - out what we want it to do
    - periodic wake from sleep to check for network activity (emails or
      chat client messages or whatever)
    - sleep on power button
    - sleep on idle 2 minutes
    - don't sleep if ssh session non-idle
 - find out why it's not doing it

   timerfd_create(CLOCK_BOOTTIME_ALARM) apparently does this: write a
   program that calls it in a loop then prods networkmanager to
   establish a connection. Anything running that wants to poll a
   server when the network is up can register with networkmanager (I
   assume) to find out when that's the case, and we should save
   the battery hit of having 16 apps spin up the radio on 16 different
   five minute intervals

* find apps
  - totp
  - megapixels
  - waydroid?

* notifications for incoming voice calls and messages.

* (hardware/pinephone) find out why it doesn't charge on usb2

* brightness setting

* firefox
  - automate layers.acceleration.force setting
  - find something faster? luakit? netsurf?
