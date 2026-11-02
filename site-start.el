;;; site-start.el --- Whatbox-only Emacs site init -*- lexical-binding: t; -*-
;;
;; Lives in ~/.local/share/emacs/site-lisp/ next to eink-theme.el, so it is
;; part of this Emacs build, not of the shared ~/.config/emacs git config.
;; Emacs loads it before init.el (unless started with --no-site-file).
;;
;; On a terminal frame (yaft on the reMarkable, via tmux/mosh) replace whatever
;; theme init.el chose with the three-tone `eink' theme. Depth 90 puts this
;; after init.el's own window-setup-hook, which loads modus-operandi.

(add-to-list 'custom-theme-load-path
             (file-name-directory (or load-file-name buffer-file-name)))

(add-hook 'window-setup-hook
          (lambda ()
            (unless (display-graphic-p)
              (mapc #'disable-theme custom-enabled-themes)
              (load-theme 'eink t)))
          90)

;;; site-start.el ends here
