(in-package :cl-user)
(defpackage walpurgisblog.comments
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly)
  (:export :get-comments
           :get-comment
           :create-comment
           :update-comment
           :rate-comment
           :delete-comment))

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
     (where (:= :article article))
     (order-by (:desc :created_at)))
   :as 'comments))

(defun create-comment (body article &optional (user 0) username)
  (when (string= "" username)
    (setf username "Guest"))
  (handler-case 
      (execute
       (insert-into :comments
         (set= :user user
               :username username
               :body body
               :article article
               :rating 0
               :created_at (local-time:now)
               :updated_at (local-time:now))))
    (error (e) e)))

(defun update-comment (id username body)
  (execute
   (update :comments
     (set= :username   username
           :body       body
           :updated_at (local-time:now))
     (where (:= :id id)))))

(defun rate-comment (id)
  (execute
   (update :comments
     (set= :rating (:+ :rating 1))
     (where (:= :id id)))))

(defun delete-comment (id)
  (execute
   (delete-from :comments
     (where (:= :id id)))))
