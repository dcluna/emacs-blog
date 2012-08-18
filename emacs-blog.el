;;;;;;;;;;;;;;;;
;; Emacs-blog ;;
;;;;;;;;;;;;;;;;

(setq emacs-blog-org-directory "~/emacs-blog/org-files")

(defvar emacs-blog-host "ec2-50-112-8-39.us-west-2.compute.amazonaws.com/" "Host for my blog")

(defun date-list-compare (x y)
  "Compares two lists in the form (Y M d) and returns if the first is the minor of the two."
  (let ((date-values '(365 30 1)))
    (< (apply '+ (mapcar* '* x date-values))
       (apply '+ (mapcar* '* y date-values)))))

(defun sort-blog-files-by-date (emacs-blog-log-list &optional reversed)
  "Sorts emacs-blog-log-list by date"
  (let ((sorted (sort emacs-blog-log-list (lambda (x y) 
                                            (let ((date1 (nth 2 x))
                                                  (date2 (nth 2 y)))
                                              (date-list-compare date1 date2))))))
    (if reversed
        (reverse sorted)
      sorted)))

(defvar
  emacs-blog-index
  (sort-blog-files-by-date `(("criacao.org" "Criando um blog com EmacsLisp" (2012 08 18))))
  "Files to be shown in the blog index. The format is: (filename post-name date)")

(defun emacs-blog-index-to-html (index-entry)
  "Returns the HTML for one index entry.
The entry format is: (filename post-name date)"
  (format "<a href=\"%s\">%s</a>" (concat emacs-blog-host "br/" (nth 0 index-entry)) (nth 1 index-entry)))

(defun emacs-blog-html-index (&optional files)
  "Returns an HTML index of the blog files, sorted by date."
  (let ((emacs-blog-index (if files
                              files
                            emacs-blog-index))))
  (mapconcat 'emacs-blog-index-to-html emacs-blog-index "<br/>\n"))

(defun elnode-org-handler (httpcon)
  (elnode-docroot-for emacs-blog-org-directory
      with org-file
      on httpcon
      do (with-current-buffer (find-file-noselect org-file)
           (let ((org-html
                  ;; This might throw errors so you could condition-case it
                  (org-export-as-html 3 nil nil 'string)))
             (elnode-send-html httpcon org-html)))))

;; (defun br-file-handler (httpcon))

(defvar
   emacs-blog-routes
   '(;; ((format "^%s//br" emacs-blog-host) . br-file-handler)
     ((format "^%s//br/\\(.*\\)" emacs-blog-host) . org-handler)
     ("^.*//\\(.*\\)" . elnode-webserver)))

(elnode-start 'elnode-org-handler :port 8010 :host elnode-init-host)
