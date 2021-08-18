(in-package :cl-user)
(defpackage walpurgisblog.articles
  (:use :cl
        :walpurgisblog.models
        :sxql
        :datafly)
  (:export  :get-articles
            :create-article
            :get-article))

(in-package :walpurgisblog.articles)


;; (defun get-article (id)
;;   (retrieve-one
;;    (select :*
;;      (from :articles)
;;      (where (:= :id id)))
;;    :as 'articles))

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
     (where (:like :title (concatenate 'string "%" title "%"))))
   :as 'articles))

(defun create-article (title body attachments user)
  (execute
   (insert-into :articles
     (set= :title title
           :body body
           :attachments attachments
           :user user
           :created_at (local-time:now)
           :updated_at (local-time:now)))))
