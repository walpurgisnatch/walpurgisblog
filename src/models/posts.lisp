(in-package :cl-user)
(defpackage walpurgisblog.posts
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly)
  (:export  :get-posts
            :create-post
            :get-post))

(in-package :walpurgisblog.posts)


(defun get-post (id)
  (retrieve-one
   (select :*
     (from :posts)
     (where (:= :id id)))
   :as 'posts))

(defun get-posts (&optional (title ""))
  (retrieve-all
   (select :*
     (from :posts)
     (where (:like :title (concatenate 'string "%" title "%"))))
   :as 'posts))

(defun create-post (title body attachments user)
  (execute
   (insert-into :posts
     (set= :title title
           :body body
           :attachments attachments
           :user user
           :created_at (local-time:now)
           :updated_at (local-time:now)))))
