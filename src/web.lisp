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

;(datafly:connect-toplevel :postgres :database-name "walpurgisblog" :username "walpurgisblog" :password "walpurgisblog")
;(setf datafly:*connection* nil)


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

(defroute ("/api/*" :method :DELETE) ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (next-route))

(defroute ("/api/*" :method :PUT) ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (next-route))

(defroute ("/*" :method :OPTIONS) ()
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (setf (getf (response-headers *response*) :Access-Control-Allow-Headers) "*")
  (setf (getf (response-headers *response*) :Access-Control-Allow-Methods) "*")  
  (next-route))

(defroute ("/login" :method :POST) (&key (|username| "") (|password| ""))
  (setf (getf (response-headers *response*) :Access-Control-Allow-Origin) "*")
  (let ((token (login |username| |password|)))
    (if token
        (render-json (append (get-user-list (from-token 'id token)) (list :token token)))
        (throw-code 400))))

(defroute ("/api/signup" :method :POST) (&key |username| |email| |password| (|status| ""))
  (print (create-user |username| |email| |password| :status |status|))
  (throw-code 200))

(defroute "/logout" ()
  (logout))

(defroute "/api/users" (&key |token|)
  (required-authorization (|token| :role 0)
    (render-json (get-users))))

(defroute "/api/user" (&key |token|)
  (render-json (get-user (from-token 'id |token|))))

(defroute "/api/articles" ()
  (render-json (get-articles)))

(defroute "/api/article/:id" (&key id)
  (render-json (get-article id)))

(defroute ("/api/articles" :method :POST) (&key |title| |body| |attachments| |user|)
  (render-json (create-article |title| |body| |attachments| |user|)))

(defroute "/api/comments/:id" (&key id)
  (render-json (get-comments id)))

(defroute ("/api/comments" :method :POST) (&key |body| |article| |user| |username|)
  (unless (create-comment |body| |article| |user| |username|)
    (throw-code 200)))

(defroute ("/api/comment/:id" :method :DELETE) (&key id)
  (unless (delete-comment id)
    (throw-code 200)))

(defroute ("/api/article/:id" :method :DELETE) (&key id)
  (unless (delete-article id)
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
