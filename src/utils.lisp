(in-package :cl-user)
(defpackage :walpurgisblog.utils
  (:use :cl
        :sxql
        :cl-annot.class
        :datafly)
  (:export :from-token
           :key
           :wildcard
           :model-update))

(in-package :walpurgisblog.utils)

(defun from-token (var token)
  (handler-case 
      (cdr (assoc (string var) (jose:inspect-token token) :test #'equalp))
    (error nil)))

(defun key (arg)
  (intern (string arg) :keyword))

(defun wildcard (string)
  (concatenate 'string "%" string "%"))
  
;;;; CRUD

(defmacro model-update (table where &rest cols)
  "update users (:id 1) :name john :sname doe"
  `(execute
    (update ,(key table)
        (set= ,@(loop for col in cols collect col)
         :updated_at (local-time:now))
        (where (:= ,@where)))))

(defmacro find-where (table where)
  (let ((data (gensym)))
    `(let ((,data (retrieve-all
                   (select :*
                     (from ,(key table))
                     (where ,where)
                     :as ',table))))
       (if (and (consp ,data) (null (cdr ,data)))
           (car ,data)
           ,data))))
