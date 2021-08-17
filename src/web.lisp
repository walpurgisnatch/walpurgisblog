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

(connect-toplevel :postgres :database-name "hack" :username "hack" :password "hack")

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(defmethod lack.component:call :around ((app <web>) env)
  (let ((datafly:*connection*
          (apply #'datafly:connect-cached (cdr (assoc :maindb (config :databases))))))
    (prog1
        (call-next-method))))
(clear-routing-rules *web*)

(defun login (name pass)
  (handler-case 
      (if (cl-pass:check-password pass (getf (get-user name) :pass))      
          (setf (gethash :user *session*) name)
          nil)
    (error (e) nil)))

(defun logout ()
  (setf (gethash :user *session*) nil))

(defun logged-in-p ()
  (gethash :user *session*))

(defmacro required-authorization (&rest body)
  `(if (logged-in-p)
       (progn ,@body)
       (throw-code 403)))

;;
;; Routing rules

(defroute "/login" (&key |name| |pass|)
  (if (login |name| |pass|)
      (redirect "/welcome")
      (render-json '("User not found."))))

(defroute "/logout" ()
  (logout)
  (redirect "/welcome"))

(defroute "/" ()
  (render #P"index.html"))

(defroute "/welcome" (&key (|name| "Guest"))
  (format nil "Welcome, ~A" (or (logged-in-p) |name|)))

(defroute "/wrong" ()
  (redirect "/welcome?name=jerk"))

(defroute "/*.json" ()
  (setf (getf (response-headers *response*) :content-type) "application/json")
  (next-route))

(defroute "/users" ()
  (required-authorization 
   (render-json (get-users))))

(defroute "/test" (&key (|name| "vic"))
  (render-json (get-test |name|)))

;;
;; Error pages

(defmethod on-exception ((app <web>) (code (eql 404)))
  (declare (ignore app))
  (merge-pathnames #P"_errors/404.html"
                   *template-directory*))

(defmethod on-exception ((app <web>) (code (eql 400)))
  (declare (ignore app))
  (render-json '("Wrong arguments.")))

(defmethod on-exception ((app <web>) (code (eql 403)))
  (declare (ignore app))
  (render-json '("Not authorized.")))
