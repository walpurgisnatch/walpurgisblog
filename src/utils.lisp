(in-package :cl-user)
(defpackage :walpurgisblog.utils
  (:use :cl)
  (:export :from-token))

(in-package :walpurgisblog.utils)

(defun from-token (var token)
  (handler-case 
      (cdr (assoc (string var) (jose:inspect-token token) :test #'equalp))
    (error nil)))

(defun key (arg)
  (intern (string arg) :keyword))
  
