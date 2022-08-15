(in-package :cl-user)
(defpackage walpurgisblog.schema
  (:use :cl :sxql :cl-annot.class :mito))

(in-package :walpurgisblog.schema)

(mito:connect-toplevel :postgres :database-name "walpurgisblog" :username "walpurgisblog" :password "walpurgisblog")

(defun ensure-tables ()
  (mapcar #'ensure-table-exists '(users articles comments)))

(defun migrate-tables ()
  (mapcar #'migrate-table '(users articles comments)))

(deftable users ()
  ((name          :col-type (:varchar 64))
   (email         :col-type (:varchar 128))
   (pass          :col-type (:varchar 128))
   (status        :col-type (or (:varchar 256) :null))
   (rating        :col-type :integer)
   (role          :col-type :integer)))

(deftable articles ()
  ((type          :col-type (or (:varchar 64) :null))
   (title         :col-type (:varchar 64))
   (body          :col-type :text)
   (attachments   :col-type (or (:varchar 128) :null))
   (user          :references users)
   (rating        :col-type :integer)))

(deftable comments ()
  ((body          :col-type :text)
   (user          :col-type (or :bigint :null))
   (username      :col-type (or (:varchar 64) :null))
   (article       :references articles)
   (rating        :col-type :integer)))


(ensure-tables)
(migrate-tables)

