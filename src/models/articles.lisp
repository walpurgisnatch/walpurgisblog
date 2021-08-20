(in-package :cl-user)
(defpackage walpurgisblog.articles
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly)
  (:export  :get-articles
            :get-article
            :create-article
            :last-user-article
            :update-article
            :delete-article
            :rate-article))

(in-package :walpurgisblog.articles)


(defun get-article (id)
  (let ((article (retrieve-one
                  (select :*
                    (from :articles)
                    (where (:= :id id)))
                  :as 'articles)))
    (setf (articles-comments article) (articles-coms article))
    article))

(defun get-articles (&optional (title ""))
  (retrieve-all
   (select :*
     (from :articles)
     (where (:like :title (concatenate 'string "%" title "%")))
     (order-by (:desc :created_at)))
   :as 'articles))

(defun last-user-article (user)
  (retrieve-one
   (select :id
     (from :articles)
     (where (:= :user user))
     (order-by (:desc :created_at)))))

(defun create-article (title body attachments user)
  (handler-case 
      (execute
       (insert-into :articles
         (set= :title title
               :body body
               :attachments attachments
               :user user
               :rating 0
               :created_at (local-time:now)
               :updated_at (local-time:now))
         (returning :id)))
    (error (e) e)))


(defun update-article (id title body attachments rating)
  (execute 
   (update :articles
     (set= :title title
           :body body
           :attachments attachments
           :rating rating)
     (where (:= :id id)))))

(defun rate-article (id)
  (execute
   (update :articles
     (set= :rating (:+ :rating 1))
     (where (:= :id id)))))

(defun delete-article (id)
  (execute 
   (delete-from :articles
     (where (:= :id id)))))

