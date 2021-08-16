(defsystem "walpurgisblog-test"
  :defsystem-depends-on ("prove-asdf")
  :author "<Walpurgisnatch>"
  :license ""
  :depends-on ("walpurgisblog"
               "prove")
  :components ((:module "tests"
                :components
                ((:test-file "walpurgisblog"))))
  :description "Test system for walpurgisblog"
  :perform (test-op (op c) (symbol-call :prove-asdf :run-test-system c)))
