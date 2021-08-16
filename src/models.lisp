(in-package :cl-user)
(defpackage walpurgisblog.models
  (:use :cl :mito))

(in-package :walpurgisblog.models)

(mito:connect-toplevel :postgres :database-name "hack" :username "hack" :password "hack")

(defun ensure-tables ()
  (mapcar #'ensure-table-exists '(users posts)))

(defun migrate-tables ()
  (mapcar #'migrate-table '(users posts)))

;(ensure-table-exists 'users)
;(print (migration-expressions 'users))
;(migrate-table 'users)

(deftable users ()
  ((name :col-type (:varchar 64))
   (email :col-type (:varchar 128))
   (pass :col-type (:varchar 128))
   (status :col-type (or (:varchar 256) :null))
   (rating :col-type :integer)
   (role :col-type :integer)))

(deftable posts ()
  ((title :col-type (:varchar 64))
   (body :col-type (:varchar 2048))
   (user-id :references users))
  (:unique-keys body))


(ensure-tables)


