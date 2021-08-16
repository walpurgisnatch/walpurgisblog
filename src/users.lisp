(in-package :cl-user)
(defpackage walpurgisblog.users
  (:use :cl :walpurgisblog.db :sxql :datafly)
  (:export :search-test
           :get-users))

(in-package :walpurgisblog.users)

(syntax:use-syntax :annot)

(defstruct user
  id
  name
  email
  pass
  status
  created-at
  updated-at
  rating)

(defun search-test (name)
  (with-connection (db)
    (retrieve-one
     (select :*
       (from :users)
       (where (:= :name name)))
     :as 'user)))


(defun get-users ()
  (with-connection (db)  
    (retrieve-all
     (select :*
       (from :users))
     :as 'user)))


@export
(defun create-user (name mail pass &optional status)
  (with-connection (db)
    (execute
     (insert-into :users
       (set= :name name
             :email mail
             :pass pass
             :status status)))))

;(create-user "vic" "kawemirs@gmail.com" "1234" "moves")
;(print (get-users))
