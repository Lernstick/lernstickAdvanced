# lernstickAdvanced
buildscripts for school centric Debian Live distributions

packages needed on a Debian system to run this script:
* dialog
* gfxboot
* libhtml-parser-perl
* live-build
* rsync
* zsync

## Additional ISO variants

### Minimal Moodle + RDP ISO

Use `./build_proxam_moodle_rdp_iso.sh` to create a stripped-down GNOME-based image
for Moodle exams and Windows Remote Desktop access.

This build profile:
- keeps only the shared core package lists required to boot the Lernstick image
- removes the default desktop, education and flatpak package sets
- skips the ProXam exam-client installation hook
- adds Firefox ESR, Remmina and a small launcher that opens Moodle in kiosk mode
	or starts the RDP client

Before distributing the image, adjust the generated config file inside the image:
- `/etc/proxam-moodle-rdp.conf`
- set `MOODLE_URL` to your Moodle course or quiz URL
- optionally set `REMMINA_PROFILE` to a pre-provisioned `.remmina` profile path
