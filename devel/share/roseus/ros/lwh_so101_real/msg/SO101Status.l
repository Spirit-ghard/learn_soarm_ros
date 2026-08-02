;; Auto-generated. Do not edit!


(when (boundp 'lwh_so101_real::SO101Status)
  (if (not (find-package "LWH_SO101_REAL"))
    (make-package "LWH_SO101_REAL"))
  (shadow 'SO101Status (find-package "LWH_SO101_REAL")))
(unless (find-package "LWH_SO101_REAL::SO101STATUS")
  (make-package "LWH_SO101_REAL::SO101STATUS"))

(in-package "ROS")
;;//! \htmlinclude SO101Status.msg.html
(if (not (find-package "STD_MSGS"))
  (ros::roseus-add-msgs "std_msgs"))


(defclass lwh_so101_real::SO101Status
  :super ros::object
  :slots (_header _connected _torque_enabled _read_only _command_blocked _port _message ))

(defmethod lwh_so101_real::SO101Status
  (:init
   (&key
    ((:header __header) (instance std_msgs::Header :init))
    ((:connected __connected) nil)
    ((:torque_enabled __torque_enabled) nil)
    ((:read_only __read_only) nil)
    ((:command_blocked __command_blocked) nil)
    ((:port __port) "")
    ((:message __message) "")
    )
   (send-super :init)
   (setq _header __header)
   (setq _connected __connected)
   (setq _torque_enabled __torque_enabled)
   (setq _read_only __read_only)
   (setq _command_blocked __command_blocked)
   (setq _port (string __port))
   (setq _message (string __message))
   self)
  (:header
   (&rest __header)
   (if (keywordp (car __header))
       (send* _header __header)
     (progn
       (if __header (setq _header (car __header)))
       _header)))
  (:connected
   (&optional (__connected :null))
   (if (not (eq __connected :null)) (setq _connected __connected)) _connected)
  (:torque_enabled
   (&optional (__torque_enabled :null))
   (if (not (eq __torque_enabled :null)) (setq _torque_enabled __torque_enabled)) _torque_enabled)
  (:read_only
   (&optional (__read_only :null))
   (if (not (eq __read_only :null)) (setq _read_only __read_only)) _read_only)
  (:command_blocked
   (&optional (__command_blocked :null))
   (if (not (eq __command_blocked :null)) (setq _command_blocked __command_blocked)) _command_blocked)
  (:port
   (&optional __port)
   (if __port (setq _port __port)) _port)
  (:message
   (&optional __message)
   (if __message (setq _message __message)) _message)
  (:serialization-length
   ()
   (+
    ;; std_msgs/Header _header
    (send _header :serialization-length)
    ;; bool _connected
    1
    ;; bool _torque_enabled
    1
    ;; bool _read_only
    1
    ;; bool _command_blocked
    1
    ;; string _port
    4 (length _port)
    ;; string _message
    4 (length _message)
    ))
  (:serialize
   (&optional strm)
   (let ((s (if strm strm
              (make-string-output-stream (send self :serialization-length)))))
     ;; std_msgs/Header _header
       (send _header :serialize s)
     ;; bool _connected
       (if _connected (write-byte -1 s) (write-byte 0 s))
     ;; bool _torque_enabled
       (if _torque_enabled (write-byte -1 s) (write-byte 0 s))
     ;; bool _read_only
       (if _read_only (write-byte -1 s) (write-byte 0 s))
     ;; bool _command_blocked
       (if _command_blocked (write-byte -1 s) (write-byte 0 s))
     ;; string _port
       (write-long (length _port) s) (princ _port s)
     ;; string _message
       (write-long (length _message) s) (princ _message s)
     ;;
     (if (null strm) (get-output-stream-string s))))
  (:deserialize
   (buf &optional (ptr- 0))
   ;; std_msgs/Header _header
     (send _header :deserialize buf ptr-) (incf ptr- (send _header :serialization-length))
   ;; bool _connected
     (setq _connected (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _torque_enabled
     (setq _torque_enabled (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _read_only
     (setq _read_only (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; bool _command_blocked
     (setq _command_blocked (not (= 0 (sys::peek buf ptr- :char)))) (incf ptr- 1)
   ;; string _port
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _port (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;; string _message
     (let (n) (setq n (sys::peek buf ptr- :integer)) (incf ptr- 4) (setq _message (subseq buf ptr- (+ ptr- n))) (incf ptr- n))
   ;;
   self)
  )

(setf (get lwh_so101_real::SO101Status :md5sum-) "c33d318113afe8fe8fae361a1d7da675")
(setf (get lwh_so101_real::SO101Status :datatype-) "lwh_so101_real/SO101Status")
(setf (get lwh_so101_real::SO101Status :definition-)
      "std_msgs/Header header
bool connected
bool torque_enabled
bool read_only
bool command_blocked
string port
string message

================================================================================
MSG: std_msgs/Header
# Standard metadata for higher-level stamped data types.
# This is generally used to communicate timestamped data 
# in a particular coordinate frame.
# 
# sequence ID: consecutively increasing ID 
uint32 seq
#Two-integer timestamp that is expressed as:
# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')
# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')
# time-handling sugar is provided by the client library
time stamp
#Frame this data is associated with
string frame_id

")



(provide :lwh_so101_real/SO101Status "c33d318113afe8fe8fae361a1d7da675")


