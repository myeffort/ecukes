#!/usr/bin/emacs --script

;;; ecukes.el --- Cucumber for Emacs

;; Copyright (C) 2010 Johan Andersson

;; Author: Johan Andersson <johan.rejeep@gmail.com>
;; Maintainer: Johan Andersson <johan.rejeep@gmail.com>
;; Version: 0.0.1
;; Keywords: test
;; URL: http://github.com/rejeep/ecukes

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:

;; Add the current directory to the load path.
(add-to-list 'load-path (file-name-directory load-file-name))

;; Require Ecukes packages.
(require 'ecukes-init)

(defvar ecukes-feature-files '()
  "List of all feature files.")
(setq ecukes-feature-files (ecukes-init-feature-files argv))

;; Make sure there are features passed in by the user.
(unless ecukes-feature-files
  (error "You did not provide any features"))

(dolist (feature-file ecukes-feature-files)
  (let ((feature (ecukes-parse-feature feature-file)))

    )
  )

;;; ecukes.el ends here