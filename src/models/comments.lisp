(in-package :cl-user)
(defpackage walpurgisblog.comments
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly)
  (:export  :get-comments
            :create-comment
            :get-comment))

(in-package :walpurgisblog.comments)


(defun get-comment (id)
  (retrieve-one
   (select :*
     (from :comments)
     (where (:= :id id)))
   :as 'comments))

(defun get-comments (article)
  (retrieve-all
   (select :*
     (from :comments)
     (where (:= :article article)))
   :as 'comments))

(defun create-comment (body article &optional (user 0) (username "Guest"))
  (execute
   (insert-into :comments
     (set= :user user
           :username username
           :body body
           :article article
           :rating 0
           :created_at (local-time:now)
           :updated_at (local-time:now)))))
