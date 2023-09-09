pgve.pl - Perl Golf Visual Editor
=================================

This is a small experiment of writing a minimalist visual editor in Perl.

The minified Perl script is 1400 bytes. It runs on perl 5.36 (Debian's
`perl-base`) and requires the `stty` and `tput` utilities as well as an
interactive `bash` compiled with Readline support (all of these are `Essential`
in Debian).

Run it with a list of file names to edit in sequence. All editor commands act
on whole lines; to edit individual lines use the `e` command which will use
bash's readline support to edit this line. There is a clipboard and a "hint
string" available which are kept across edited files. The "hint string" is sent
to Readline before editing the line so you can use readline's clipboard to move
parts of it into the actual line.

General commands
----------------

- `j`: move cursor down
- `k`: move cursor up
- `v`: toggle visual mode (in visual mode you can mark lines to act on)
- `ZZ`: Save and continue editing the next file
- `QQ`: Discard changes and continue editing the next file
- `:`: Run a Perl command with `$_` bound to the current line (in a loop in
  case of visual mode)
- `d`: Delete line(s) and place into clipboard
- `y`: Copy line(s) to clipboard
- `h`: append line(s) to hint string
- `J`: Join two lines (or more in visual mode) using spaces

Visual mode commands
--------------------

- `@`: Run a Perl command with `@_` bound to the selected lines

Non-visual mode commands
------------------------

- `o`: Open empty line below cursor
- `O`: Open empty line above cursor
- `e`: Edit current line in Readline
- `S`: Split current line; press repeatedly to decide split point
- `p`: Paste clipboard below cursor
- `P`: Paste clipboard above cursor
