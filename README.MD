![Preivew](./assets/demo.gif)
# Options Select
> _An interactive cross-platform select menu for BASH & ZSH with no dependencies._
## Install
<!-- TODO: How to install section -->
Either [source] the script or install it directly into preferred `/bin` directory.

For Debian based systems install into the `~/.local/bin/`
(replace the link with current repo one):
```bash
curl https://raw.githubusercontent.com/hinell/options-select-bash/master/options.select.bash -o ~/.local/bin/options.select.bash && chmod +x ~/.local/bin/options.select.bash

```

[source]: https://tldp.org/HOWTO/Bash-Prompt-HOWTO/x237.html


### Uninstall

```bash
$ rm ~/.local/bin/options.select.bash
```

## Usage

List options with custom prompt.

```bash
# src/myscript.bash
# . options-select.bash

# Input
options=(one two three);
prompt="Please, select choice! [%index]/[%total]";

# Selection
# Options var is passed without dollar sign
options.select options $prompt;

# The output
echo "INDEX        => $?"
echo "INDEX        => $SELECTED_IDX"
echo "SELECTED     => $SELECTED" # <- Selected value
```

### Examples
Run `./examples.bash` file from the termian to see the script in action.

## Support Status
No any guarantee unless paid for maintanance.

### Platforms

Terminals:
* Bash - 5.1.4
* Zsh - 5.8 

Operating systems:
* Ubuntu 21.04
* Kubuntu 21.04

## How it works? 
It relies heavily on ANSI and Terminal Emulation Software escape codes. It was written over a course of 7 days and under huge load of coffee cups 🍵. You are welcome to tip me off you like.

## Credits 
* Huge respect goes to [Alexander K.] on StackOverflow who inspired this script.

### See also
* [inquirer.js] - Terminal user interface written in JS for NodeJS
* [survey] - Similar, but written in Go
* `man console_codes`
* `man terminfo`

A collection of common interactive command line user interfaces. 

[Alexander K.]: https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu/415155
[inquirer.js]: https://github.com/SBoudrias/Inquirer.js
[survey]: https://github.com/AlecAivazis/survey

----
 Copyright (C) 2021- hinel@github.com