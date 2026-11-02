# eink-theme: an Emacs theme for the reMarkable 2 tablet

A colour theme for Emacs running on a reMarkable 2's e-ink screen, through the
[yaft](https://github.com/timower/rM2-stuff) terminal emulator. It uses the
only things that screen path can actually show: black, white, a checkerboard
grey, **bold**, <u>underline</u> and reverse video. Nothing else. No colours
that turn to mud, no italics that silently vanish, no subtle backgrounds that
flicker.

It was written by Claude (Anthropic's AI model, Claude Fable 5.1) for Elliott
W, after reading yaft's renderer to find out what the display can do, and
tested over mosh and tmux from a reMarkable 2 with a Type Folio keyboard.

## Why an e-ink terminal needs its own theme

Every existing "monochrome" or "e-ink" Emacs theme assumes a greyscale
display. The reMarkable 2 panel does have 16 grey levels, but yaft never uses
them while you type. From `apps/yaft/screen.cpp` in rM2-stuff:

1. Each cell's foreground and background colour is reduced to a brightness,
   `(54·R + 182·G + 19·B) / 255`.
2. That brightness becomes one of exactly **three tones**:
   `Black` (≤ 85), `Dither` (86–169, a 1-pixel checkerboard), `White` (≥ 170).
3. If foreground and background land on the same tone, yaft nudges one of
   them apart, so nothing is ever truly invisible.
4. Cells are painted with the panel's fast **A2/DU waveforms, which are
   1-bit**. The checkerboard is the only "grey" that survives a partial
   redraw; real greys appear only on a full GC16 refresh.
5. Attributes: **bold** uses a bolder glyph, **underline** swaps the two tones
   on the last pixel row of the cell, **reverse** swaps them everywhere.
   yaft's `yaft-256color` terminfo has no `sitm` (italic) and no `dim`.

So the useful palette is: default text, one grey, bold, underline, reverse.
That is the whole theme.

## What it looks like

| Role | Rendering |
|---|---|
| Body text | black on white (terminal defaults) |
| De-emphasis: comments, tags, dates, DONE, marginalia, inactive mode line | checkerboard grey (`#808080`) |
| Emphasis: headings, keywords, prompts, function names | bold |
| Links, dates, matches, type names | underline |
| Selection, current completion, TODO keywords, active mode line | reverse |

355 face settings cover: the Emacs basics, `font-lock`, Org (document, headings,
TODO/DONE, tags, links, blocks, tables, checkboxes, clocks, columns) and the
Org agenda, Evil (ex search and substitute), Vertico, Marginalia, Orderless,
Consult, Denote, Deft, Citar, Dired, Info, Help, Compilation, Diff/Ediff,
Whitespace, Writegood, Flyspell/Flymake, Elfeed, Eshell/Comint, Calendar,
Outline, Markdown, Customize, Rainbow Delimiters (all depths plain: no rainbow
on e-ink) and Spacious Padding.

Every face is specified with the `t` display class, so the theme behaves the
same on any frame; it simply looks best where only those three tones exist.

## Install

### Option A: terminal frames only, outside your dotfiles (recommended)

This is how it runs on the author's server, where the same `~/.config/emacs`
is shared with a Mac that should keep its GUI theme. The two files go into the
`site-lisp` directory of the Emacs build itself, so the shared config stays
untouched. Emacs loads `site-start.el` before `init.el` unless started with
`--no-site-file`.

```sh
# Find your site-lisp directory:
emacs --batch --eval '(dolist (p load-path) (when (string-match-p "site-lisp" p) (princ (concat p "\n"))))'
# For an Emacs built with --prefix=$HOME/.local it is:
cp eink-theme.el site-start.el ~/.local/share/emacs/site-lisp/
```

`site-start.el` adds a late `window-setup-hook` (depth 90, so it runs after
your init's own theme loading) that, on non-graphic frames only, disables
whatever theme was enabled and loads `eink`.

### Option B: plain theme install

```elisp
(add-to-list 'custom-theme-load-path "/path/to/remarkable2-emacs-theme/")
(load-theme 'eink t)
```

### Option C: conditional in your init

```elisp
(add-to-list 'custom-theme-load-path "/path/to/remarkable2-emacs-theme/")
(add-hook 'window-setup-hook
          (lambda ()
            (if (display-graphic-p)
                (load-theme 'modus-operandi t)   ; or whatever you like on a GUI
              (load-theme 'eink t))))
```

## Two things outside the theme that matter

**tmux: use `tmux-256color`, not `screen-256color`.** Emacs renders
`:inverse-video` with the terminfo *standout* capability. tmux's
`screen-256color` entry defines standout as `ESC[3m` (italic), which yaft
ignores, so TODO keywords and the mode line silently lose their reverse video.
`tmux-256color` defines standout as `ESC[7m`. In `~/.tmux.conf`:

```
set -g default-terminal "tmux-256color"
```

Existing tmux windows keep their old `TERM`; open a new one.

**Give the server yaft's terminfo.** yaft sets `TERM=yaft-256color`. Copy its
compiled entry (on the tablet, installed by the Vellum package at
`/home/root/.vellum/share/yaft/yaft-256color`) to `~/.terminfo/y/yaft-256color`
on the machine you ssh or mosh into, and `tput colors` reports 256 there.

## The stack this was built on

- reMarkable 2, OS 3.28, Type Folio keyboard
- [Vellum](https://github.com/vellum-dev/vellum) package manager, XOVI,
  AppLoad 0.6.0, yaft 0.1.4
- mosh and tmux into a remote Linux box; Emacs 30.2 built there with
  `--without-x`
- Evil, Org, Denote, Vertico/Marginalia/Orderless/Consult, Citar, Deft

## Known limits

- Org's hidden leading stars use the `org-hide` face (white on white). Because
  yaft nudges equal tones apart, they show as a faint checkerboard rather
  than disappearing. Turning off `org-hide-leading-stars` is the clean fix if
  it bothers you.
- `:slant italic` is set on nothing, because yaft cannot draw it. Comments are
  grey instead.
- Blink exists in the terminfo. The theme does not use it, and neither should
  anything else on e-ink.

## Credits

Written by Claude (Anthropic), from a reading of yaft's `screen.cpp` and the
`yaft-256color` / `screen-256color` / `tmux-256color` terminfo entries, for
Elliott W's reMarkable 2 setup. yaft is by [timower](https://github.com/timower).

## License

GPL-3.0-or-later, like Emacs itself. See `LICENSE`.
