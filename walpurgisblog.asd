(defsystem "walpurgisblog"
  :version "0.1.0"
  :author "<Walpurgisnatch>"
  :license ""
  :depends-on ("clack"
               "lack"
               "caveman2"
               "envy"
               "cl-ppcre"
               "uiop"

               ;; for @route annotation
               "cl-syntax-annot"

               ;; HTML Template
               "djula"

               ;; for DB
               "datafly"
               "sxql"
               "mito"
               "cl-pass")
  :components ((:module "src"
                :components
                ((:file "models/users" :depends-on ("db"))
                 (:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "config"))))
  :description ""
  :in-order-to ((test-op (test-op "walpurgisblog-test"))))
