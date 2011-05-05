;;
;; filename: sydict.el
;; Description:
;; Author: sylvester
;; Maintainer: sylvester (Shi Yudi)
;; Created: Thu Jan 27 13:30:12 2011 (+0800)
;; Version: 0.3
;; Last-Updated: Tue Feb  1 00:48:52 2011 (+0800)
;;           By: sylvester
;;     Update #: 62
;; URL: http://blog.meecoder.com/
;; Keywords: sydict dictionary emacs stardict
;; Compatibility: emacs & linux
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;; This script is aim to make a simple interface to look up a word.
;; It's now based on oald dictionary, and is a brief impelement.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Change Log:
;; 0.1 run a shell to look up a word by provided function
;;        "sydict-look-up-word".
;;
;; 0.2 write the word into result buffer.
;;
;; 0.3 Mon Jan 31 2010
;;     1. write result into a partical buffer, defalut "*sydict*"
;;     2. using help mode to view result.
;;     3. using `with-help-window' for displaying result that
;;        help shrinking length of function of  `sydict-look-up-word'.
;;     4. setting a new function `sydict-buffer'.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(load "sydict-index")

;; some options to customize sydict
(defvar sydict-prog-name "sydict"
  "Program name of which to look for explain of a word.")

(defvar sydict-dict-path "/etc/sydict/oald.dict"
  "Indicator of which explain's database to use.")

(defvar sydict-buffer-name "*sydict*"
  "Buffer name of displaying explain of word.
Using in the function `sydict-buffer' to create buffer.")

(defvar sydict-history-file-name ".sydict_history"
  "Name of file to store word which user has looked for.  As it
to say, sydict history will store in
'~/sydict-history-file-name'. This varible will uses only if you
set `sydict-save-history' to 't'. You should execute this command
if you want to disable save history of which you looked before:

    (setq sydict-save-history nil)

And function `sydict-toggle-save-history' will toggle this
varible.")

(defvar sydict-save-history t
  "Indicator of whether word you have looked for will be saved
into file `sydict-history-file-name'")

(defun sydict-toggle-save-history ()
  "Toggle whether should save word you have looked for into file `sydict-history-file-name'."
  (setq sydict-save-history (not sydict-save-history)))

(defun sydict-buffer ()
  "Return buffer name of sydict set in `sydict-buffer-name'.
Create it if not exist yet."
  (buffer-name
   (get-buffer-create sydict-buffer-name)))

;; interface to use to look up a word
(defun sydict-look-up-word (index)
  "Interactive function to look up a word.
**Remember not to use paragment before you know what it really means."
  (interactive
   (let  ((word-list (mapcar 'car sydict-alist))
	  (predict-word (sydict-word-at-point))
	  val)
     ;; read word from mini buffer
     (setq val (completing-read
		(if predict-word
		    (format "Word (default %s): " predict-word)
		  "Word: ")
		word-list nil t nil nil
		(and predict-word
		     (symbol-name predict-word))))
     ;; return the word index if you write a word or
     ;; have default word, nil otherwise.
     (list (if (equal val "")
	       nil
	     ;; 单词匹配时忽略大小写
	     (assoc-ignore-case val sydict-alist))))) ;end of interactive
  ;; show explain of word
  (if (null index)
      (message "You didn't specify a function")
    (save-excursion
	(with-help-window (sydict-buffer)
	  (let ((aword (car index))
		(start (int-to-string (nth 1 index)))
		(length (int-to-string (nth 2 index))))
	    (call-process sydict-prog-name
			  nil sydict-buffer-name nil
			  (expand-file-name sydict-dict-path) start length)
	    (with-current-buffer (sydict-buffer)
	      (goto-char (point-min))
	      (insert (format "<* %s *> \n" aword))
	      (if sydict-save-history
		  (append-to-file
		   (concat aword "\n") nil
		   (concat "~/" sydict-history-file-name)))))))))

(defun sydict-word-at-point ()
  (save-excursion
    ;; 删除(backward-word)，修正光标在单词第一个字母取词时取到前一个单词的Bug.
    (let ((word (word-at-point)))
      ;; 单词匹配忽略大小写
      (if (assoc-ignore-case word sydict-alist)
	  (intern word)
	nil))))

(provide 'sydict-look-up-word)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; sydict.el ends here
