;; Auto-generated. Do not edit!


(when (boundp 'lwh_so101_real::Gripper)
  (if (not (find-package "LWH_SO101_REAL"))
    (make-package "LWH_SO101_REAL"))
  (shadow 'Gripper (find-package "LWH_SO101_REAL")))
(unless (find-package "LWH_SO101_REAL::GRIPPER")
  (make-package "LWH_SO101_REAL::GRIPPER"))
(unless (find-package "LWH_SO101_REAL::GRIPPERREQUEST")
  (make-package "LWH_SO101_REAL::GRIPPERREQUEST"))
(unless (find-package "LWH_SO101_REAL::GRIPPERRESPONSE")
  (make-package "LWH_SO101_REAL::GRIPPERRESPONSE"))

(in-package "ROS")





(defclass lwh_so101_real::GripperRequest
  :super ros::object
  :slots (_gripper_position ))

(defmethod lwh_so101_real::GripperRequest
  (:init
   (&key
    ((:gripper_position __gripper_position) 0.0)
    )
   (send-super :init)
   (setq _gripper_position (float __gripper_position))
   self)
  (:gripper_position
   (&optional __gripper_position)
   (if __gripper_position (setq _gripper_position __gripper_position)) _gripper_position)
  (:serialization-length
   ()
   (+
    ;; float64 _gripper_position
    8
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; float64 _gripper_position
       (sys::poke _gripper_position (send s :buffer) (send s :count) :double) (incf (stream-count s) 8)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; float64 _gripper_position
     (setq _gripper_position (sys::peek buf ptr- :double)) (incf ptr- 8)
   ;;
   self)
  )

(defclass lwh_so101_real::GripperResponse
  :super ros::object
  :slots (_status _message ))

(defmethod lwh_so101_real::GripperResponse
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

(defclass lwh_so101_real::Gripper
  :super ros::object
  :slots ())

(setf (get lwh_so101_real::Gripper :md5sum-) "24faaffe681998cb080d78f790b7098c")
(setf (get lwh_so101_real::Gripper :datatype-) "lwh_so101_real/Gripper")
(setf (get lwh_so101_real::Gripper :request) lwh_so101_real::GripperRequest)
(setf (get lwh_so101_real::Gripper :response) lwh_so101_real::GripperResponse)

(defmethod lwh_so101_real::GripperRequest
  (:response () (instance lwh_so101_real::GripperResponse :init)))

(setf (get lwh_so101_real::GripperRequest :md5sum-) "24faaffe681998cb080d78f790b7098c")
(setf (get lwh_so101_real::GripperRequest :datatype-) "lwh_so101_real/GripperRequest")
(setf (get lwh_so101_real::GripperRequest :definition-)
      "float64 gripper_position
---
bool status
string message

")

(setf (get lwh_so101_real::GripperResponse :md5sum-) "24faaffe681998cb080d78f790b7098c")
(setf (get lwh_so101_real::GripperResponse :datatype-) "lwh_so101_real/GripperResponse")
(setf (get lwh_so101_real::GripperResponse :definition-)
      "float64 gripper_position
---
bool status
string message

")



(provide :lwh_so101_real/Gripper "24faaffe681998cb080d78f790b7098c")


