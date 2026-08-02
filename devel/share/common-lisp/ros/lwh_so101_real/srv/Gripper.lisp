; Auto-generated. Do not edit!


(cl:in-package lwh_so101_real-srv)


;//! \htmlinclude Gripper-request.msg.html

(cl:defclass <Gripper-request> (roslisp-msg-protocol:ros-message)
  ((gripper_position
    :reader gripper_position
    :initarg :gripper_position
    :type cl:float
    :initform 0.0))
)

(cl:defclass Gripper-request (<Gripper-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Gripper-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Gripper-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<Gripper-request> is deprecated: use lwh_so101_real-srv:Gripper-request instead.")))

(cl:ensure-generic-function 'gripper_position-val :lambda-list '(m))
(cl:defmethod gripper_position-val ((m <Gripper-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:gripper_position-val is deprecated.  Use lwh_so101_real-srv:gripper_position instead.")
  (gripper_position m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Gripper-request>) ostream)
  "Serializes a message object of type '<Gripper-request>"
  (cl:let ((bits (roslisp-utils:encode-double-float-bits (cl:slot-value msg 'gripper_position))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 32) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 40) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 48) bits) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 56) bits) ostream))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Gripper-request>) istream)
  "Deserializes a message object of type '<Gripper-request>"
    (cl:let ((bits 0))
      (cl:setf (cl:ldb (cl:byte 8 0) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 8) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 16) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 24) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 32) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 40) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 48) bits) (cl:read-byte istream))
      (cl:setf (cl:ldb (cl:byte 8 56) bits) (cl:read-byte istream))
    (cl:setf (cl:slot-value msg 'gripper_position) (roslisp-utils:decode-double-float-bits bits)))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Gripper-request>)))
  "Returns string type for a service object of type '<Gripper-request>"
  "lwh_so101_real/GripperRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Gripper-request)))
  "Returns string type for a service object of type 'Gripper-request"
  "lwh_so101_real/GripperRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Gripper-request>)))
  "Returns md5sum for a message object of type '<Gripper-request>"
  "24faaffe681998cb080d78f790b7098c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Gripper-request)))
  "Returns md5sum for a message object of type 'Gripper-request"
  "24faaffe681998cb080d78f790b7098c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Gripper-request>)))
  "Returns full string definition for message of type '<Gripper-request>"
  (cl:format cl:nil "float64 gripper_position~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Gripper-request)))
  "Returns full string definition for message of type 'Gripper-request"
  (cl:format cl:nil "float64 gripper_position~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Gripper-request>))
  (cl:+ 0
     8
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Gripper-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Gripper-request
    (cl:cons ':gripper_position (gripper_position msg))
))
;//! \htmlinclude Gripper-response.msg.html

(cl:defclass <Gripper-response> (roslisp-msg-protocol:ros-message)
  ((status
    :reader status
    :initarg :status
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass Gripper-response (<Gripper-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Gripper-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Gripper-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<Gripper-response> is deprecated: use lwh_so101_real-srv:Gripper-response instead.")))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <Gripper-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:status-val is deprecated.  Use lwh_so101_real-srv:status instead.")
  (status m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Gripper-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:message-val is deprecated.  Use lwh_so101_real-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Gripper-response>) ostream)
  "Serializes a message object of type '<Gripper-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'status) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Gripper-response>) istream)
  "Deserializes a message object of type '<Gripper-response>"
    (cl:setf (cl:slot-value msg 'status) (cl:not (cl:zerop (cl:read-byte istream))))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Gripper-response>)))
  "Returns string type for a service object of type '<Gripper-response>"
  "lwh_so101_real/GripperResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Gripper-response)))
  "Returns string type for a service object of type 'Gripper-response"
  "lwh_so101_real/GripperResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Gripper-response>)))
  "Returns md5sum for a message object of type '<Gripper-response>"
  "24faaffe681998cb080d78f790b7098c")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Gripper-response)))
  "Returns md5sum for a message object of type 'Gripper-response"
  "24faaffe681998cb080d78f790b7098c")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Gripper-response>)))
  "Returns full string definition for message of type '<Gripper-response>"
  (cl:format cl:nil "bool status~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Gripper-response)))
  "Returns full string definition for message of type 'Gripper-response"
  (cl:format cl:nil "bool status~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Gripper-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Gripper-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Gripper-response
    (cl:cons ':status (status msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Gripper)))
  'Gripper-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Gripper)))
  'Gripper-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Gripper)))
  "Returns string type for a service object of type '<Gripper>"
  "lwh_so101_real/Gripper")