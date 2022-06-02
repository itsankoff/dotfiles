# Installation guide for OSX
This is a poor man's attempt to set up a platform agnostic development environment
through overcomplicated shell scripts. Currently working mostly for macOS. Use
`General Setup` if you use other OS (Linux, Unix, BSD).  

Platform specific setups are described by separate section.

## [] Prerequisites
* Make sure the executing user `echo $USER` has access to the following sub-directories in `/usr/local`  
(_NOTE: This is not an exhaustive list_):
    * `Caskroom`
    * `Cellar`
    * `Frameworks`
    * `Homebrew`
    * `bin`
    * `include`
    * `lib`
    * `opt`
    * `sbin`
    * `share`
    * `var`
* You can ensure ownership with the following command: `sudo chown -R ${USER}:admin <dirs_listed_above>`
* Install [brew](https://brew.sh/)
* Follow brew post install instructions to populate `brew` in the environment

## Installation
* Make code structure: `mkdir -p ~/developers`
* Clone the repo: `git clone https://github.com/itsankoff/dotfiles.git`

## General setup
* 📜 Run `setup.sh`
* 🔒 It may ask you for a sudo password initially 👀
* ☕ Make yourself a coffee or a tea! ___NOTE: It is really important for the script!___
* 🚀 Happy coding!

## [] Install AirPodsConnect
* Make sure the executing user `echo $USER` has access to the following sub-directories in `/usr/local`  
* Open Script Editor
* Copy the `config/AirPodsConnect_Catalina` or `config/AirPodsConnect_BigSur+`  script in the editor
* Rename the `AirPods Pro` with yours AirPods's name. If you have apostrophe
    in your AirPods name, make sure it matches extacly in the script.
* Save the script in Applications with File Format `Application`
* Allow Accessibility access to the `AirPodsConnect` script
    * Open System Preferences -> Security And Privacy -> Privacy
    * Go to Accessibility using the left panel
    * Unlock using your credentials
    * Use the `+` button on the right panel and navigate to Applications/AirPodsConnect
    * Check the AirPodsConnect
    * Lock the settings
* Open Spotlight, type `AirPodsConnect` and hit enter
* Enjoy the 🎧

## [] OS additional setup
* Login with iCloud and calendars
    * System Preferences -> Internet Accounts -> `...`
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
* Keyboard inputs:
    * System Preferences -> Keyboard -> Inputs Sources -> EN - US and Bulgarian QUERTY
* Set home directory in finder as favorite
    * Finder -> Preferences -> Sidebar -> ${USER}
* Karabiner-Elements
    * Setup privacy and security access
    * rules
        * `fn` -> `left control`
        * `left control` -> `fn`
        * if UK keyboard layout
            * `grave_accent_and_tilde()` -> `non_us_backslash`
            * `non_us_backslash` -> `grave_accent_and_tilde`


## [] Additional iterm2 setup
* iTerm2 -> Preferences -> Profiles -> Other Actions -> Import JSON Profiles -> /path/to/dotfiles/mac/config/iterm-profile.json
* Set the profile as default
* iTerm2 -> Preferences -> Keys -> Presets -> Import... -> /path/to/dotfiles/mac/config/iterm-keys.itermkeymap
* iTerm2 -> Preferences -> Appearance -> Tabs -> Uncheck Stretch tabs to fill bar

## Troubleshooting
* [] Depending on your Mac settings you may need to allow Accessibility permissions
    for the script. Go to `Settings -> Security and Privacy -> Privacy Tab -> Accessibility -> Add permission for AirPodsConnect`
* [] `brew` failed to install due to github pub key access denied: https://github.com/Homebrew/brew/issues/52#issuecomment-208557489

## References
* AirPodsConnect Spotlight bind - [Full article](https://medium.com/@secondfret/how-to-connect-your-airpods-to-your-mac-with-a-keyboard-shortcut-9d72e786993b)
