;;; ox-tw.el --- Markdown Back-End for Org Export Engine

;;; Commentary:

;; Adapted by IZ <zannos@gmail.com>
;; from Nicolas Goaziou's markdown export module.
;; <n.goaziou@gmail.com>
;; Keywords: org, wp, markdown, tiddlywiki

;; This library implements a TiddlyWiki back-end (vanilla flavor) for
;; Org exporter, based on `html' and `markdown' back-ends.
;; See Org manual for more information.

;;; Code:

(eval-when-compile (require 'cl))
(require 'ox-html)



;;; User-Configurable Variables

(defgroup org-export-tw nil
  "Options specific to TiddlyWiki export back-end."
  :tag "Org TiddlyWiki"
  :group 'org-export
  :version "24.4"
  :package-version '(Org . "8.0"))

(defcustom org-tw-headline-style 'atx
  "This option is not applicable to TiddlyWiki.
Style used to format headlines in MarkDown.
This variable can be set to either `atx' or `setext'."
  :group 'org-export-tw
  :type '(choice
	  (const :tag "Use \"atx\" style" atx)
	  (const :tag "Use \"Setext\" style" setext)))



;;; Define Back-End

(org-export-define-derived-backend 'tw 'html
  :export-block '("TW" "TIDDLYWIKI")
  :filters-alist '((:filter-parse-tree . org-tw-separate-elements))
  :menu-entry
  '(?m "Export to TiddlyWiki"
       ((?M "To temporary buffer"
	    (lambda (a s v b) (org-tw-export-as-tiddlywiki a s v)))
	(?m "To file" (lambda (a s v b) (org-tw-export-to-tiddlywiki a s v)))
	(?o "To file and open"
	    (lambda (a s v b)
	      (if a (org-tw-export-to-tiddlywiki t s v)
		(org-open-file (org-tw-export-to-tiddlywiki nil s v)))))))
  :translate-alist '((bold . org-tw-bold)
		     (code . org-tw-verbatim)
		     (comment . (lambda (&rest args) ""))
		     (comment-block . (lambda (&rest args) ""))
		     (example-block . org-tw-example-block)
		     (fixed-width . org-tw-example-block)
		     (footnote-definition . ignore)
		     (footnote-reference . ignore)
		     (headline . org-tw-headline)
		     (horizontal-rule . org-tw-horizontal-rule)
		     (inline-src-block . org-tw-verbatim)
		     (inner-template . org-tw-inner-template)
		     (italic . org-tw-italic)
		     (item . org-tw-item)
		     (line-break . org-tw-line-break)
		     (link . org-tw-link)
		     (paragraph . org-tw-paragraph)
		     (plain-list . org-tw-plain-list)
		     (plain-text . org-tw-plain-text)
		     (quote-block . org-tw-quote-block)
		     (quote-section . org-tw-example-block)
		     (section . org-tw-section)
		     (src-block . org-tw-example-block)
		     (template . org-tw-template)
		     (verbatim . org-tw-verbatim)))



;;; Filters

(defun org-tw-separate-elements (tree backend info)
  "Fix blank lines between elements.

TREE is the parse tree being exported.  BACKEND is the export
back-end used.  INFO is a plist used as a communication channel.

Enforce a blank line between elements.  There are three
exceptions to this rule:

  1. Preserve blank lines between sibling items in a plain list,

  2. Outside of plain lists, preserve blank lines between
     a paragraph and a plain list,

  3. In an item, remove any blank line before the very first
     paragraph and the next sub-list.

Assume BACKEND is `md'."
  (org-element-map tree (remq 'item org-element-all-elements)
    (lambda (e)
      (cond
       ((not (and (eq (org-element-type e) 'paragraph)
		  (eq (org-element-type (org-export-get-next-element e info))
		      'plain-list)))
	(org-element-put-property e :post-blank 1))
       ((not (eq (org-element-type (org-element-property :parent e)) 'item)))
       (t (org-element-put-property
	   e :post-blank (if (org-export-get-previous-element e info) 1 0))))))
  ;; Return updated tree.
  tree)



;;; Transcode Functions

;;;; Bold

(defun org-tw-bold (bold contents info)
  "Transcode BOLD object into TiddlyWiki format.
CONTENTS is the text within bold markup.  INFO is a plist used as
a communication channel."
  (format "**%s**" contents))


;;;; Code and Verbatim

(defun org-tw-verbatim (verbatim contents info)
  "Transcode VERBATIM object into TiddlyWiki format.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (let ((value (org-element-property :value verbatim)))
    (format (cond ((not (string-match "`" value)) "`%s`")
		  ((or (string-match "\\``" value)
		       (string-match "`\\'" value))
		   "`` %s ``")
		  (t "``%s``"))
	    value)))


;;;; Example Block and Src Block

(defun org-tw-example-block (example-block contents info)
  "Transcode EXAMPLE-BLOCK element into TiddlyWiki format.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  (replace-regexp-in-string
   "^" "    "
   (org-remove-indentation
    (org-export-format-code-default example-block info))))


;;;; Headline

(defun org-tw-headline (headline contents info)
  "Transcode HEADLINE element into TiddlyWiki format.
CONTENTS is the headline contents.  INFO is a plist used as
a communication channel."
  (unless (org-element-property :footnote-section-p headline)
    (let* ((level (org-export-get-relative-level headline info))
	   (title (org-export-data (org-element-property :title headline) info))
	   (todo (and (plist-get info :with-todo-keywords)
		      (let ((todo (org-element-property :todo-keyword
							headline)))
			(and todo (concat (org-export-data todo info) " ")))))
	   (tags (and (plist-get info :with-tags)
		      (let ((tag-list (org-export-get-tags headline info)))
			(and tag-list
			     (format "     :%s:"
				     (mapconcat 'identity tag-list ":"))))))
	   (priority
	    (and (plist-get info :with-priority)
		 (let ((char (org-element-property :priority headline)))
		   (and char (format "[#%c] " char)))))
	   (anchor
	    (when (plist-get info :with-toc)
	      (org-html--anchor
	       (or (org-element-property :CUSTOM_ID headline)
		   (concat "sec-"
			   (mapconcat 'number-to-string
				      (org-export-get-headline-number
				       headline info) "-"))))))
	   ;; Headline text without tags.
	   (heading (concat todo priority title)))
      (cond
       ;; Cannot create a headline.  Fall-back to a list.
       ((or (org-export-low-level-p headline info)
	    (not (memq org-tw-headline-style '(atx setext)))
	    (and (eq org-tw-headline-style 'atx) (> level 6))
	    (and (eq org-tw-headline-style 'setext) (> level 2)))
	(let ((bullet
	       (if (not (org-export-numbered-headline-p headline info)) "-"
		 (concat (number-to-string
			  (car (last (org-export-get-headline-number
				      headline info))))
			 "."))))
	  (concat bullet (make-string (- 4 (length bullet)) ? ) heading tags
		  "\n\n"
		  (and contents
		       (replace-regexp-in-string "^" "    " contents)))))
       ;; Use "Setext" style.
       ((eq org-tw-headline-style 'setext)
	(concat heading tags anchor "\n"
		(make-string (length heading) (if (= level 1) ?= ?-))
		"\n\n"
		contents))
       ;; Use "atx" style.
       (t (concat (make-string level ?#) " " heading tags anchor "\n\n" contents))))))


;;;; Horizontal Rule

(defun org-tw-horizontal-rule (horizontal-rule contents info)
  "Transcode HORIZONTAL-RULE element into TiddlyWiki format.
CONTENTS is the horizontal rule contents.  INFO is a plist used
as a communication channel."
  "---")


;;;; Italic

(defun org-tw-italic (italic contents info)
  "Transcode ITALIC object into TiddlyWiki format.
CONTENTS is the text within italic markup.  INFO is a plist used
as a communication channel."
  (format "*%s*" contents))


;;;; Item

(defun org-tw-item (item contents info)
  "Transcode ITEM element into TiddlyWiki format.
CONTENTS is the item contents.  INFO is a plist used as
a communication channel."
  (let* ((type (org-element-property :type (org-export-get-parent item)))
	 (struct (org-element-property :structure item))
	 (bullet (if (not (eq type 'ordered)) "-"
		   (concat (number-to-string
			    (car (last (org-list-get-item-number
					(org-element-property :begin item)
					struct
					(org-list-prevs-alist struct)
					(org-list-parents-alist struct)))))
			   "."))))
    (concat bullet
	    (make-string (- 4 (length bullet)) ? )
	    (case (org-element-property :checkbox item)
	      (on "[X] ")
	      (trans "[-] ")
	      (off "[ ] "))
	    (let ((tag (org-element-property :tag item)))
	      (and tag (format "**%s:** "(org-export-data tag info))))
	    (and contents
		 (org-trim (replace-regexp-in-string "^" "    " contents))))))


;;;; Line Break

(defun org-tw-line-break (line-break contents info)
  "Transcode LINE-BREAK object into TiddlyWiki format.
CONTENTS is nil.  INFO is a plist used as a communication
channel."
  "  \n")


;;;; Link

(defun org-tw-link (link contents info)
  "Transcode LINE-BREAK object into TiddlyWiki format.
CONTENTS is the link's description.  INFO is a plist used as
a communication channel."
  (let ((link-org-files-as-tw
	 (function
	  (lambda (raw-path)
	    ;; Treat links to `file.org' as links to `file.md'.
	    (if (string= ".org" (downcase (file-name-extension raw-path ".")))
		(concat (file-name-sans-extension raw-path) ".md")
	      raw-path))))
	(type (org-element-property :type link)))
    (cond
     ((member type '("custom-id" "id"))
      (let ((destination (org-export-resolve-id-link link info)))
	(if (stringp destination)	; External file.
	    (let ((path (funcall link-org-files-as-tw destination)))
	      (if (not contents) (format "<%s>" path)
		(format "[%s](%s)" contents path)))
	  (concat
	   (and contents (concat contents " "))
	   (format "(%s)"
		   (format (org-export-translate "See section %s" :html info)
			   (mapconcat 'number-to-string
				      (org-export-get-headline-number
				       destination info)
				      ".")))))))
     ((org-export-inline-image-p link org-html-inline-image-rules)
      (let ((path (let ((raw-path (org-element-property :path link)))
		    (if (not (file-name-absolute-p raw-path)) raw-path
		      (expand-file-name raw-path))))
	    (caption (org-export-data
		      (org-export-get-caption
		       (org-export-get-parent-element link)) info)))
	(format "![img](%s)"
		(if (not (org-string-nw-p caption)) path
		  (format "%s \"%s\"" path caption)))))
     ((string= type "coderef")
      (let ((ref (org-element-property :path link)))
	(format (org-export-get-coderef-format ref contents)
		(org-export-resolve-coderef ref info))))
     ((equal type "radio") contents)
     ((equal type "fuzzy")
      (let ((destination (org-export-resolve-fuzzy-link link info)))
	(if (org-string-nw-p contents) contents
	  (when destination
	    (let ((number (org-export-get-ordinal destination info)))
	      (when number
		(if (atom number) (number-to-string number)
		  (mapconcat 'number-to-string number "."))))))))
     ;; Link type is handled by a special function.
     ((let ((protocol (nth 2 (assoc type org-link-protocols))))
	(and (functionp protocol)
	     (funcall protocol
		      (org-link-unescape (org-element-property :path link))
		      contents
		      'md))))
     (t (let* ((raw-path (org-element-property :path link))
	       (path
		(cond
		 ((member type '("http" "https" "ftp"))
		  (concat type ":" raw-path))
		 ((string= type "file")
		  (let ((path (funcall link-org-files-as-tw raw-path)))
		    (if (not (file-name-absolute-p path)) path
		      ;; If file path is absolute, prepend it
		      ;; with "file:" component.
		      (concat "file:" path))))
		 (t raw-path))))
	  (if (not contents) (format "<%s>" path)
	    (format "[%s](%s)" contents path)))))))


;;;; Paragraph

(defun org-tw-paragraph (paragraph contents info)
  "Transcode PARAGRAPH element into TiddlyWiki format.
CONTENTS is the paragraph contents.  INFO is a plist used as
a communication channel."
  (let ((first-object (car (org-element-contents paragraph))))
    ;; If paragraph starts with a #, protect it.
    (if (and (stringp first-object) (string-match "\\`#" first-object))
	(replace-regexp-in-string "\\`#" "\\#" contents nil t)
      contents)))


;;;; Plain List

(defun org-tw-plain-list (plain-list contents info)
  "Transcode PLAIN-LIST element into TiddlyWiki format.
CONTENTS is the plain-list contents.  INFO is a plist used as
a communication channel."
  contents)


;;;; Plain Text

(defun org-tw-plain-text (text info)
  "Transcode a TEXT string into TiddlyWiki format.
TEXT is the string to transcode.  INFO is a plist holding
contextual information."
  (when (plist-get info :with-smart-quotes)
    (setq text (org-export-activate-smart-quotes text :html info)))
  ;; Protect ambiguous #.  This will protect # at the beginning of
  ;; a line, but not at the beginning of a paragraph.  See
  ;; `org-tw-paragraph'.
  (setq text (replace-regexp-in-string "\n#" "\n\\\\#" text))
  ;; Protect ambiguous !
  (setq text (replace-regexp-in-string "\\(!\\)\\[" "\\\\!" text nil nil 1))
  ;; Protect `, *, _ and \
  (setq text (replace-regexp-in-string "[`*_\\]" "\\\\\\&" text))
  ;; Handle special strings, if required.
  (when (plist-get info :with-special-strings)
    (setq text (org-html-convert-special-strings text)))
  ;; Handle break preservation, if required.
  (when (plist-get info :preserve-breaks)
    (setq text (replace-regexp-in-string "[ \t]*\n" "  \n" text)))
  ;; Return value.
  text)


;;;; Quote Block

(defun org-tw-quote-block (quote-block contents info)
  "Transcode QUOTE-BLOCK element into TiddlyWiki format.
CONTENTS is the quote-block contents.  INFO is a plist used as
a communication channel."
  (replace-regexp-in-string
   "^" "> "
   (replace-regexp-in-string "\n\\'" "" contents)))


;;;; Section

(defun org-tw-section (section contents info)
  "Transcode SECTION element into TiddlyWiki format.
CONTENTS is the section contents.  INFO is a plist used as
a communication channel."
  contents)


;;;; Template

(defun org-tw-inner-template (contents info)
  "Return body of document after converting it to TiddlyWiki syntax.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  ;; Make sure CONTENTS is separated from table of contents and
  ;; footnotes with at least a blank line.
  (org-trim (org-html-inner-template (concat "\n" contents "\n") info)))

(defun org-tw-template (contents info)
  "Return complete document string after TiddlyWiki conversion.
CONTENTS is the transcoded contents string.  INFO is a plist used
as a communication channel."
  contents)



;;; Interactive function

;;;###autoload
(defun org-tw-export-as-tiddlywiki (&optional async subtreep visible-only)
  "Export current buffer to a TiddlyWiki buffer.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible
through the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Export is done in a buffer named \"*Org MD Export*\", which will
be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (org-export-to-buffer 'md "*Org MD Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-tw-convert-region-to-tw ()
  "Assume the current region has org-mode syntax, and convert it to TiddlyWiki.
This can be used in any buffer.  For example, you can write an
itemized list in org-mode syntax in a TiddlyWiki buffer and use
this command to convert it."
  (interactive)
  (org-export-replace-region-by 'md))


;;;###autoload
(defun org-tw-export-to-tiddlywiki (&optional async subtreep visible-only)
  "Export current buffer to a TiddlyWiki file.

If narrowing is active in the current buffer, only export its
narrowed part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through
the `org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree
at point, extracting information from the headline properties
first.

When optional argument VISIBLE-ONLY is non-nil, don't export
contents of hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'md outfile async subtreep visible-only)))


(provide 'ox-tw)

;; Local variables:
;; generated-autoload-file: "org-loaddefs.el"
;; End:

;;; ox-tw.el ends here
