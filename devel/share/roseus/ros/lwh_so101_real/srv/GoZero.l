;; Auto-generated. Do not edit!


(when (boundp 'lwh_so101_real::GoZero)
  (if (not (find-package "LWH_SO101_REAL"))
    (make-package "LWH_SO101_REAL"))
  (shadow 'GoZero (find-package "LWH_SO101_REAL")))
(unless (find-package "LWH_SO101_REAL::GOZERO")
  (make-package "LWH_SO101_REAL::GOZERO"))
(unless (find-package "LWH_SO101_REAL::GOZEROREQUEST")
  (make-package "LWH_SO101_REAL::GOZEROREQUEST"))
(unless (find-package "LWH_SO101_REAL::GOZERORESPONSE")
  (make-package "LWH_SO101_REAL::GOZERORESPONSE"))

(in-package "ROS")





(defclass lwh_so101_real::GoZeroRequest
  :super ros::object
  :slots (_confirm ))

(defmethod lwh_so101_real::GoZeroRequest
  (:init
   (&key
    ((:confirm __confirm) nil)
    )
   (send-super :init)
   (setq _confirm __confirm)
   self)
  (:confirm
   (&optional (__confirm :null))
   (if (not (eq __confirm :null)) (setq _confirm __confirm)) _confirm)
  (:serialization-length
   ()
   (+
    ;; bool _confirm
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _confirm
       (if _confirm (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _confirm
     (setq _confirm (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(defclass lwh_so101_real::GoZeroResponse
  :super ros::object
  :slots (_status _message ))

(defmethod lwh_so101_real::GoZeroResponse
  (:init
   (&key
    ((:status __status) nil)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _status __status)
   (setq _message (string __message))
   self)
  (:status
   (&optional (__status :null))
   (if (not (eq __status :null)) (setq _status __status)) _status)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; bool _status
    1
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _status
       (if _status (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _status
     (setq _status (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass lwh_so101_real::GoZero
  :super ros::object
  :slots ())

(setf (get lwh_so101_real::GoZero :md5sum-) "afbed5da1b16c7ab8a2d82fcdedd5932")
(setf (get lwh_so101_real::GoZero :datatype-) "lwh_so101_real/GoZero")
(setf (get lwh_so101_real::GoZero :request) lwh_so101_real::GoZeroRequest)
(setf (get lwh_so101_real::GoZero :response) lwh_so101_real::GoZeroResponse)

(defmethod lwh_so101_real::GoZeroRequest
  (:response () (instance lwh_so101_real::GoZeroResponse :init)))

(setf (get lwh_so101_real::GoZeroRequest :md5sum-) "afbed5da1b16c7ab8a2d82fcdedd5932")
(setf (get lwh_so101_real::GoZeroRequest :datatype-) "lwh_so101_real/GoZeroRequest")
(setf (get lwh_so101_real::GoZeroRequest :definition-)
      "bool confirm
---
bool status
string message

")

(setf (get lwh_so101_real::GoZeroResponse :md5sum-) "afbed5da1b16c7ab8a2d82fcdedd5932")
(setf (get lwh_so101_real::GoZeroResponse :datatype-) "lwh_so101_real/GoZeroResponse")
(setf (get lwh_so101_real::GoZeroResponse :definition-)
      "bool confirm
---
bool status
string message

")



(provide :lwh_so101_real/GoZero "afbed5da1b16c7ab8a2d82fcdedd5932")


