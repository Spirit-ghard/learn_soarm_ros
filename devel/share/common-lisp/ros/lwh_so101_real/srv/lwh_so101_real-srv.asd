
(cl:in-package :asdf)

(defsystem "lwh_so101_real-srv"
  :depends-on (:roslisp-msg-protocol :roslisp-utils )
  :components ((:file "_package")
    (:file "Enable" :depends-on ("_package_Enable"))
    (:file "_package_Enable" :depends-on ("_package"))
    (:file "GoZero" :depends-on ("_package_GoZero"))
    (:file "_package_GoZero" :depends-on ("_package"))
    (:file "Gripper" :depends-on ("_package_Gripper"))
    (:file "_package_Gripper" :depends-on ("_package"))
  ))