(in-package :cl-user)
(defpackage walpurgisblog.users
  (:use :cl :walpurgisblog.db :sxql :datafly)
  (:export :get-user
   :get-users
           :create-user
           :get-test))

(in-package :walpurgisblog.users)

(defun get-user (name)
  (retrieve-one
   (select :*
     (from :users)
     (where (:= :name name)))))

(defun get-users (&optional (name ""))
  (retrieve-all
   (select :*
     (from :users)
     (where (:like :name (concatenate 'string "%" name "%"))))))

(defun create-user (name mail pass &key status (rating 0) (role 3))
  (execute
   (insert-into :users
     (set= :name name
           :email mail
           :pass (cl-pass:hash pass)
           :status status
           :rating rating
           :role role))))
