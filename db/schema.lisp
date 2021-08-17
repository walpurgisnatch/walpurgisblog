(in-package :cl-user)
(defpackage walpurgisblog.schema
  (:use :cl :sxql :cl-annot.class :mito))

(in-package :walpurgisblog.schema)

(mito:connect-toplevel :postgres :database-name "hack" :username "hack" :password "hack")


(defun ensure-tables ()
  (mapcar #'ensure-table-exists '(users posts comments)))

(defun migrate-tables ()
  (mapcar #'migrate-table '(users posts comments)))

(deftable users ()
  ((name          :col-type (:varchar 64))
   (email         :col-type (:varchar 128))
   (pass          :col-type (:varchar 128))
   (status        :col-type (or (:varchar 256) :null))
   (rating        :col-type :integer)
   (role          :col-type :integer)))

(deftable posts ()
  ((title         :col-type (:varchar 64))
   (body          :col-type :text)
   (attachments   :col-type (:varchar 128))
   (user          :references users)))

(deftable comments ()
  ((body          :col-type :text)
   (user          :references users)
   (post          :references posts)
   (rating        :col-type :integer)))


(ensure-tables)
(migrate-tables)

