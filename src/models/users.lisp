(in-package :cl-user)
(defpackage walpurgisblog.users
  (:use :cl
        :walpurgisblog.models
        :sxql
        :cl-annot.class
        :datafly)
  (:export :get-user
           :find-user
           :get-users
           :create-user))

(in-package :walpurgisblog.users)


(defun get-user (id)
  (retrieve-one
   (select :*
     (from :users)
     (where (:= :id id)))
   :as 'users))

(defun find-user (name)
  (retrieve-one
   (select :*
     (from :users)
     (where (:= :name name)))
   :as 'users))

(defun get-users (&optional (name ""))
  (retrieve-all
   (select :*
     (from :users)
     (where (:like :name (concatenate 'string "%" name "%"))))
   :as 'users))

(defun create-user (name mail pass &key status (rating 0) (role 3))
  (execute
   (insert-into :users
     (set= :name name
           :email mail
           :pass (cl-pass:hash pass)
           :status status
           :rating rating
           :role role
           :created_at (local-time:now)
           :updated_at (local-time:now)))))
