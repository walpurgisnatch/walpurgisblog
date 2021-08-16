(in-package :cl-user)
(defpackage walpurgisblog.web
  (:use :cl
        :caveman2
        :walpurgisblog.config
        :walpurgisblog.view
        :walpurgisblog.db
        :datafly
        :sxql
        :walpurgisblog.users)
  (:export :*web*))
(in-package :walpurgisblog.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(clear-routing-rules *web*)

;;
;; Routing rules

(defroute "/" ()
  (render #P"index.html"))

(defroute "/welcome" (&key (|name| "Guest"))
  (format nil "Welcome, ~A" |name|))

(defroute "/wrong" ()
  (redirect "/welcome?name=jerk"))

(defroute "/*.json" ()
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (next-route))

(defroute "/test.json" (&key |name|)
  (let ((person (search-test |name|)))
    (render-json person)))

(defroute "/users" ()
  (render-json (get-users)))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))
