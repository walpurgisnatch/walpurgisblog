(in-package :cl-user)
(defpackage walpurgisblog.models
  (:use :cl :mito))

(in-package :walpurgisblog.models)

(mito:connect-toplevel :postgres :database-name "walpurgisblog" :username "walpurgisblog" :password "walpurgisblog")

(deftable users ()
  ((name :col-type (:varchar 64))
   (email :col-type (:varchar 128))
   (pass :col-type (:varchar 64))
   (status :col-type (or (:varchar 256) :null))
   (rating :col-type :integer
           :initform 0)))

(ensure-table-exists 'users)
(print (migration-expressions 'users))
(migrate-table 'users)

(deftable posts ()
  ((title :col-type (:varchar 64))
   (body :col-type (:varchar 2048))
   (user-id :references users))
  (:unique-keys body))

(ensure-table-exists 'posts)



