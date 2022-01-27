# Installation guide for OSX
This is poor man's attempt to set up a platform agnostic development environment
through overcomplicated shell scripts.

## [macOS] Prerequisites
* Make sure the executing user has access to the following directories (NOTE: This is not an exhaustive list):
    * Caskroom
    * Cellar
    * Frameworks
    * Homebrew
    * bin
    * etc
    * include
    * lib
    * opt
    * sbin
    * share
    * var
* You can ensure ownership with the following command: `sudo chown -R ${USER}:admin <dirs_listed_above>`

## General setup
* 📜 Run `setup.sh`
* It may ask you for a sudo password initially
* ☕ Make yourself a coffee or a tea! **NOTE**: It is really important for the script!
* 🚀 Happy coding!

## [macOS] Install AirPodsConnect
* Open Script Editor
* Copy the `config/AirPodsConnect` script in the editor
* Rename the `AirPods Pro` with yours AirPods's name. If you have apostrophe
    in your AirPods name, make sure it matches extacly in the script.
* Save the script in Applications with File Format `Application`
* Allow Accessibility access to the AirPodsConnect script
    * Open System Preferences -> Security And Privacy -> Privacy
    * Go to Accessibility using the left panel
    * Unlock using your credentials
    * Use the `+` button on the right panel and nagivate to Applications/AirPodsConnect
    * Check the AirPodsConnect
    * Lock the settings
* Open Spotlight, type `AirPodsConnect` and hit enter
* Enjoy the 🎧

## [macOS] OS additional setup
* Click on the Battery icon at the status back -> Check `Show Percentage`
* Open Settings
* Go to Date & Time -> Clock
* Check - `Display the time with seconds`
* Go to Dock
* Check `Automatically hide and show Dock`
* Go to Hot Corners
* Left top - `-`
* Left bottom - `Desktop`
* Right top - `Notification center`
* Right bottom - `Desktop`
* Go to Appearance
* Highligh color: `Graphite`
* Theme - `Dark`
* Go to Keyboards -> Shortcuts -> Mission Control
* Uncheck `Move left a space` (`^<-`)
* Uncheck `Move right a space` (`^->`)
* Make Menu Bar dark
    * System Preferences -> Accessibility -> Display -> Reduce Transperancy
* Battery percentage
    * System Preferences -> Dock and Menu Bar -> Battery -> Show Percentage

## [macOS] Additional iterm2 setup
* iTerm2 -> Preferences -> Profiles -> Other Actions -> Import JSON Profiles -> /path/to/dotfiles/mac/config/iterm-profile.json
* Set the profile as default
* iTerm2 -> Preferences -> Keys -> Presets -> Import... -> /path/to/dotfiles/mac/config/iterm-keys.itermkeymap
* iTerm2 -> Preferences -> Appearance -> Uncheck Stretch tabs to fill bar

## Troubleshooting
* Depending on your Mac settings you may need to allow Accessibility permissions
    for the script. Go to `Settings -> Security and Privacy -> Privacy Tab -> Accessibility -> Add permission for AirPodsConnect`

## References
* AirPodsConnect Spotlight bind - [Full article](https://medium.com/@secondfret/how-to-connect-your-airpods-to-your-mac-with-a-keyboard-shortcut-9d72e786993b)
