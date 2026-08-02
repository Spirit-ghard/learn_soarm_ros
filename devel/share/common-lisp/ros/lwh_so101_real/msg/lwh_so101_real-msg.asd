
(cl:in-package :asdf)

(defsystem "lwh_so101_real-msg"
  :depends-on (:roslisp-msg-protocol :roslisp-utils :std_msgs-msg
)
  :components ((:file "_package")
    (:file "SO101Status" :depends-on ("_package_SO101Status"))
    (:file "_package_SO101Status" :depends-on ("_package"))
  ))