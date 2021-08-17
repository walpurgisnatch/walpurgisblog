(in-package :cl-user)
(defpackage :walpurgisblog.utilites
  (:use :cl)
  (:export :id-))

(in-package :walpurgisblog.utilites)

(defun id- (list)
  (getf list :id))
