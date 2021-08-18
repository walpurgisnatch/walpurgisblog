(in-package :cl-user)
(defpackage walpurgisblog.models
  (:use :cl :sxql :cl-annot.class :datafly)
  (:export :users-articles
           :articles-owner
           :articles-coms
           :comments-owner
           :comments-place))

(in-package :walpurgisblog.models)

(syntax:use-syntax :annot)

@export-accessors
@export
(defmodel (users (:inflate created-at #'datetime-to-timestamp)
                 (:inflate updated-at #'datetime-to-timestamp)
                 (:has-many (articles articles)
                            (select :*
                              (from :articles)
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

@export-accessors
@export
(defmodel (articles (:inflate created-at #'datetime-to-timestamp)
                    (:inflate updated-at #'datetime-to-timestamp)
                    (:has-a (owner users) (where (:= :id user)))
                    (:has-many (coms comments)
                               (select :*
                                 (from :comments)
                                 (where (:= :article id))
                                 (order-by (:desc :created_at)))))
  id
  title
  body
  attachments
  user
  comments
  created-at
  updated-at)

@export-accessors
@export
(defmodel (comments (:inflate created-at #'datetime-to-timestamp)
                    (:inflate updated-at #'datetime-to-timestamp)
                    (:has-a (owner users) (where (:= :id user)))
                    (:has-a (place articles) (where (:= :id article))))

  id
  user
  username
  body
  article
  rating
  created-at
  updated-at)
