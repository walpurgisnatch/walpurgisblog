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
               "cl-syntax-annot"
               "djula"
               "datafly"
               "sxql"
               "mito"
               "cl-pass"
               "jose"
               "local-time")
  :components ((:module "src"
                :components
                ((:file "models/users" :depends-on ("models"))
                 (:file "models/posts" :depends-on ("models"))
                 (:file "main" :depends-on ("config" "view" "db"))
                 (:file "web" :depends-on ("view"))
                 (:file "view" :depends-on ("config"))
                 (:file "db" :depends-on ("config"))
                 (:file "models" :depends-on ("config" "db"))
                 (:file "config")))
               (:module "db"
                :components
                ((:file "schema"))))
  :description ""
  :in-order-to ((test-op (test-op "walpurgisblog-test"))))
