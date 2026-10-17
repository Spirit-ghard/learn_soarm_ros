; Auto-generated. Do not edit!


(cl:in-package lwh_so101_real-msg)


;//! \htmlinclude SO101Status.msg.html

(cl:defclass <SO101Status> (roslisp-msg-protocol:ros-message)
  ((header
    :reader header
    :initarg :header
    :type std_msgs-msg:Header
    :initform (cl:make-instance 'std_msgs-msg:Header))
   (connected
    :reader connected
    :initarg :connected
    :type cl:boolean
    :initform cl:nil)
   (torque_enabled
    :reader torque_enabled
    :initarg :torque_enabled
    :type cl:boolean
    :initform cl:nil)
   (read_only
    :reader read_only
    :initarg :read_only
    :type cl:boolean
    :initform cl:nil)
   (command_blocked
    :reader command_blocked
    :initarg :command_blocked
    :type cl:boolean
    :initform cl:nil)
   (port
    :reader port
    :initarg :port
    :type cl:string
    :initform "")
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass SO101Status (<SO101Status>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <SO101Status>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'SO101Status)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-msg:<SO101Status> is deprecated: use lwh_so101_real-msg:SO101Status instead.")))

(cl:ensure-generic-function 'header-val :lambda-list '(m))
(cl:defmethod header-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:header-val is deprecated.  Use lwh_so101_real-msg:header instead.")
  (header m))

(cl:ensure-generic-function 'connected-val :lambda-list '(m))
(cl:defmethod connected-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:connected-val is deprecated.  Use lwh_so101_real-msg:connected instead.")
  (connected m))

(cl:ensure-generic-function 'torque_enabled-val :lambda-list '(m))
(cl:defmethod torque_enabled-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:torque_enabled-val is deprecated.  Use lwh_so101_real-msg:torque_enabled instead.")
  (torque_enabled m))

(cl:ensure-generic-function 'read_only-val :lambda-list '(m))
(cl:defmethod read_only-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:read_only-val is deprecated.  Use lwh_so101_real-msg:read_only instead.")
  (read_only m))

(cl:ensure-generic-function 'command_blocked-val :lambda-list '(m))
(cl:defmethod command_blocked-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:command_blocked-val is deprecated.  Use lwh_so101_real-msg:command_blocked instead.")
  (command_blocked m))

(cl:ensure-generic-function 'port-val :lambda-list '(m))
(cl:defmethod port-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:port-val is deprecated.  Use lwh_so101_real-msg:port instead.")
  (port m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <SO101Status>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-msg:message-val is deprecated.  Use lwh_so101_real-msg:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <SO101Status>) ostream)
  "Serializes a message object of type '<SO101Status>"
  (roslisp-msg-protocol:serialize (cl:slot-value msg 'header) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'connected) 1 0)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'torque_enabled) 1 0)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'read_only) 1 0)) ostream)
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'command_blocked) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'port))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'port))
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <SO101Status>) istream)
  "Deserializes a message object of type '<SO101Status>"
  (roslisp-msg-protocol:deserialize (cl:slot-value msg 'header) istream)
    (cl:setf (cl:slot-value msg 'connected) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:setf (cl:slot-value msg 'torque_enabled) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:setf (cl:slot-value msg 'read_only) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:setf (cl:slot-value msg 'command_blocked) (cl:not (cl:zerop (cl:read-byte istream))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'port) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'port) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
    (cl:let ((__ros_str_len 0))
      (cl:setf (cl:ldb (cl:byte 8 0) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) __ros_str_len) (cl:read-byte istream))
      (cl:setf (cl:slot-value msg 'message) (cl:make-string __ros_str_len))
      (cl:dotimes (__ros_str_idx __ros_str_len msg)
        (cl:setf (cl:char (cl:slot-value msg 'message) __ros_str_idx) (cl:code-char (cl:read-byte istream)))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<SO101Status>)))
  "Returns string type for a message object of type '<SO101Status>"
  "lwh_so101_real/SO101Status")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'SO101Status)))
  "Returns string type for a message object of type 'SO101Status"
  "lwh_so101_real/SO101Status")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<SO101Status>)))
  "Returns md5sum for a message object of type '<SO101Status>"
  "c33d318113afe8fe8fae361a1d7da675")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'SO101Status)))
  "Returns md5sum for a message object of type 'SO101Status"
  "c33d318113afe8fe8fae361a1d7da675")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<SO101Status>)))
  "Returns full string definition for message of type '<SO101Status>"
  (cl:format cl:nil "std_msgs/Header header~%bool connected~%bool torque_enabled~%bool read_only~%bool command_blocked~%string port~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'SO101Status)))
  "Returns full string definition for message of type 'SO101Status"
  (cl:format cl:nil "std_msgs/Header header~%bool connected~%bool torque_enabled~%bool read_only~%bool command_blocked~%string port~%string message~%~%================================================================================~%MSG: std_msgs/Header~%# Standard metadata for higher-level stamped data types.~%# This is generally used to communicate timestamped data ~%# in a particular coordinate frame.~%# ~%# sequence ID: consecutively increasing ID ~%uint32 seq~%#Two-integer timestamp that is expressed as:~%# * stamp.sec: seconds (stamp_secs) since epoch (in Python the variable is called 'secs')~%# * stamp.nsec: nanoseconds since stamp_secs (in Python the variable is called 'nsecs')~%# time-handling sugar is provided by the client library~%time stamp~%#Frame this data is associated with~%string frame_id~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <SO101Status>))
  (cl:+ 0
     (roslisp-msg-protocol:serialization-length (cl:slot-value msg 'header))
     1
     1
     1
     1
     4 (cl:length (cl:slot-value msg 'port))
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <SO101Status>))
  "Converts a ROS message object to a list"
  (cl:list 'SO101Status
    (cl:cons ':header (header msg))
    (cl:cons ':connected (connected msg))
    (cl:cons ':torque_enabled (torque_enabled msg))
    (cl:cons ':read_only (read_only msg))
    (cl:cons ':command_blocked (command_blocked msg))
    (cl:cons ':port (port msg))
    (cl:cons ':message (message msg))
))
