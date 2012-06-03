;;; ein-pytools.el --- Python tools build on top of kernel

;; Copyright (C) 2012- Takafumi Arakaki

;; Author: Takafumi Arakaki

;; This file is NOT part of GNU Emacs.

;; ein-pytools.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-pytools.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-pytools.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(eval-when-compile (require 'cl))

(require 'ein-kernel)

(eval-when-compile (defvar ein:notebook)
                   (defvar ein:@connect))
(declare-function ein:$notebook-kernel "ein-notebook")
(declare-function ein:connect-get-kernel "ein-connect")

(defun ein:pytools-get-kernel ()
  (cond
   (ein:notebook (ein:$notebook-kernel ein:notebook))
   (ein:@connect (ein:connect-get-kernel))))

(defun ein:pytools-setup-hooks (kernel)
  (push (cons #'ein:pytools-add-sys-path kernel)
        (ein:$kernel-after-start-hook kernel)))

(defun ein:pytools-add-sys-path (kernel)
  (ein:kernel-execute
   kernel
   (format "__import__('sys').path.append('%s')" ein:source-dir)))

(defun ein:pytools-jump-to-source (kernel object)
  (ein:log 'info "Jumping to the source of %s..." object)
  (ein:kernel-request-stream
   kernel
   (format "__import__('ein').find_source('%s')" object)
   (lambda (string object)
     (let* ((filename-lineno (split-string string "\n"))
            (filename (car filename-lineno))
            (lineno (string-to-number (cadr filename-lineno))))
       (unless (equal filename "")
         (find-file-other-window filename)
         (goto-char (point-min))
         (forward-line (1- lineno))
         (ein:log 'info "Jumping to the source of %s...Done" object))))
   (list object)))

(defun ein:pytools-jump-to-source-command ()
  (interactive)
  (ein:pytools-jump-to-source (ein:pytools-get-kernel) (ein:object-at-point)))

(provide 'ein-pytools)

;;; ein-pytools.el ends here