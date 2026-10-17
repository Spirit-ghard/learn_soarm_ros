;; Auto-generated. Do not edit!


(when (boundp 'lwh_so101_real::Enable)
  (if (not (find-package "LWH_SO101_REAL"))
    (make-package "LWH_SO101_REAL"))
  (shadow 'Enable (find-package "LWH_SO101_REAL")))
(unless (find-package "LWH_SO101_REAL::ENABLE")
  (make-package "LWH_SO101_REAL::ENABLE"))
(unless (find-package "LWH_SO101_REAL::ENABLEREQUEST")
  (make-package "LWH_SO101_REAL::ENABLEREQUEST"))
(unless (find-package "LWH_SO101_REAL::ENABLERESPONSE")
  (make-package "LWH_SO101_REAL::ENABLERESPONSE"))

(in-package "ROS")





(defclass lwh_so101_real::EnableRequest
  :super ros::object
  :slots (_enable_request ))

(defmethod lwh_so101_real::EnableRequest
  (:init
   (&key
    ((:enable_request __enable_request) nil)
    )
   (send-super :init)
   (setq _enable_request __enable_request)
   self)
  (:enable_request
   (&optional (__enable_request :null))
   (if (not (eq __enable_request :null)) (setq _enable_request __enable_request)) _enable_request)
  (:serialization-length
   ()
   (+
    ;; bool _enable_request
    1
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _enable_request
       (if _enable_request (write-byte -1 s) (write-byte 0 s))
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _enable_request
     (setq _enable_request (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;;
   self)
  )

(defclass lwh_so101_real::EnableResponse
  :super ros::object
  :slots (_enable_response _message ))

(defmethod lwh_so101_real::EnableResponse
  (:init
   (&key
    ((:enable_response __enable_response) nil)
    ((:message __message) "")
    )
   (send-super :init)
   (setq _enable_response __enable_response)
   (setq _message (string __message))
   self)
  (:enable_response
   (&optional (__enable_response :null))
   (if (not (eq __enable_response :null)) (setq _enable_response __enable_response)) _enable_response)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; bool _enable_response
    1
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; bool _enable_response
       (if _enable_response (write-byte -1 s) (write-byte 0 s))
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; bool _enable_response
     (setq _enable_response (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(defclass lwh_so101_real::Enable
  :super ros::object
  :slots ())

(setf (get lwh_so101_real::Enable :md5sum-) "94311001937e1d83c38bf078453474ea")
(setf (get lwh_so101_real::Enable :datatype-) "lwh_so101_real/Enable")
(setf (get lwh_so101_real::Enable :request) lwh_so101_real::EnableRequest)
(setf (get lwh_so101_real::Enable :response) lwh_so101_real::EnableResponse)

(defmethod lwh_so101_real::EnableRequest
  (:response () (instance lwh_so101_real::EnableResponse :init)))

(setf (get lwh_so101_real::EnableRequest :md5sum-) "94311001937e1d83c38bf078453474ea")
(setf (get lwh_so101_real::EnableRequest :datatype-) "lwh_so101_real/EnableRequest")
(setf (get lwh_so101_real::EnableRequest :definition-)
      "bool enable_request
---
bool enable_response
string message

")

(setf (get lwh_so101_real::EnableResponse :md5sum-) "94311001937e1d83c38bf078453474ea")
(setf (get lwh_so101_real::EnableResponse :datatype-) "lwh_so101_real/EnableResponse")
(setf (get lwh_so101_real::EnableResponse :definition-)
      "bool enable_request
---
bool enable_response
string message

")



(provide :lwh_so101_real/Enable "94311001937e1d83c38bf078453474ea")


