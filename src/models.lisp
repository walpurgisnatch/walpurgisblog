(in-package :cl-user)
(defpackage walpurgisblog.models
  (:use :cl :sxql :cl-annot.class :datafly)
  (:export :users-posts
           :posts-owner))

(in-package :walpurgisblog.models)

(syntax:use-syntax :annot)

@export-accessors
@export
(defmodel (posts (:inflate created-at #'datetime-to-timestamp)
                 (:inflate updated-at #'datetime-to-timestamp)
                 (:has-a (owner users) (where (:= :id user))))
  id
  title
  body
  attachments
  user
  created-at
  updated-at)

@export-accessors
@export
(defmodel (users (:inflate created-at #'datetime-to-timestamp)
                 (:inflate updated-at #'datetime-to-timestamp)
                 (:has-many (posts posts)
                            (select :*
                              (from :posts)
                              (where (:= :user id))
                              (order-by (:desc :created_at)))))
  id
  name
  email
  status
  rating
  role
  created-at
  updated-at)

