(in-package :cl-user)
(defpackage walpurgisblog.articles
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly
        :walpurgisblog.utils)
  (:export  :get-articles
            :get-article
            :create-article
            :last-user-article
            :update-article
            :delete-article
            :rate-article
            :update-test
            :create-test))

(in-package :walpurgisblog.articles)


(defun get-article (id)
  (let ((article (car (find-where articles (:= :id id)))))
    (setf (articles-comments article) (articles-coms article))
    article))

(defun get-articles (&optional (title ""))
  (find-where articles (:like :title (wildcard title))))

(defun find-articles (&rest args &key (statement :and) (title "") user (limit 10) (offset 0) (order-by `(:desc :created_at)))
  `(find-where articles (,statement ,@(only-vals args)) :limit limit :offset offset :order-by order-by))

(defun last-user-article (user)
  (retrieve-one
   (select :id
     (from :articles)
     (where (:= :user user))
     (order-by (:desc :created_at)))))

(defun create-article (title body attachments user)
  (handler-case 
      (retrieve-one
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

