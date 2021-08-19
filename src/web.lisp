(in-package :cl-user)
(defpackage walpurgisblog.web
  (:use :cl
        :caveman2
        :walpurgisblog.config
        :walpurgisblog.view
        :walpurgisblog.db
        :datafly
        :sxql
   :walpurgisblog.models
   :walpurgisblog.utils
   :walpurgisblog.users
   :walpurgisblog.articles
   :walpurgisblog.comments)
  (:export :*web*))
(in-package :walpurgisblog.web)

;; for @route annotation
(syntax:use-syntax :annot)

;;
;; Application

;(datafly:connect-toplevel :postgres :database-name "hack" :username "hack" :password "hack")

(defclass <web> (<app>) ())
(defvar *web* (make-instance '<web>))
(defmethod lack.component:call :around ((app <web>) env)
  (let ((datafly:*connection*
          (apply #'datafly:connect-cached (cdr (assoc :maindb (config :databases))))))
    (prog1
        (call-next-method))))
(clear-routing-rules *web*)

(defvar *key* (ironclad:ascii-string-to-byte-array "my$ecret"))

(defun login (name pass)
  (handler-case
      (let ((user (login-user name pass)))
        (if user
            (jose:encode :hs256 *key* user)
            nil))
    (error nil)))

(defun logout ()
  (setf (gethash :user *session*) nil))

(defun privileged (token &optional name role)
  (handler-case
      (let ((data (jose:inspect-token token)))
        (cond (name
                (equal name (cdr (assoc "name" data :test #'equalp)))
                data)
              (role
                (equal role (cdr (assoc "role" data :test #'equalp)))
                data)
              (t t)))
    (error nil)))

(defmacro required-authorization ((token &key name role) &body body) 
  `(if (privileged ,token ,name ,role)
       (progn ,@body)
       (throw-code 403)))

;;
;; Routing rules

(defroute "/api/*" ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (next-route))

(defroute ("/api/*" :method :POST) ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (next-route))

(defroute ("/*" :method :OPTIONS) ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (setf (getf (response-headers *response*) :Access-Control-Allow-Headers) "*")
  (next-route))

(defroute ("/login" :method :POST) (&key (|username| "") (|password| ""))
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (let ((token (login |username| |password|)))
    (if token
        (redirect (format nil "/welcome?token=~a" token))
        (render-json '("User not found.")))))

(defroute ("/api/signup" :method :POST) (&key |username| |email| |password| (|status| ""))
  (unless (create-user |username| |email| |password| :status |status|)
    (throw-code 200)))

(defroute "/logout" ()
  (logout)
  (redirect "/welcome"))

(defroute "/welcome" (&key (|name| "Guest") (|token| ""))
  (format nil "Welcome, ~A" (or (from-token 'name |token|) |name|)))

(defroute "/wrong" ()
  (redirect "/welcome?name=jerk"))

(defroute "/api/users" (&key |token|)
  (required-authorization (|token| :role 0)
   (render-json (get-users))))

(defroute "/api/articles" ()
  (render-json (get-articles)))

(defroute "/api/article/:id" (&key id)
  (render-json (get-article id)))

(defroute ("/api/articles" :method :POST) (&key |title| |body| |attachments| |user|)
  (unless (create-article |title| |body| |attachments| |user|)
    (render-json (last-user-article |user|))))

(defroute "/api/comments/:id" (&key id)
  (render-json (get-comments id)))

(defroute ("/api/comments" :method :POST) (&key |body| |article| |user| |username|)
  (unless (create-comment |body| |article| |user| |username|)
    (throw-code 200)))

(defroute "*" ()
  (render #P"index.html"))

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
