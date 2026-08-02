; Auto-generated. Do not edit!


(cl:in-package lwh_so101_real-srv)


;//! \htmlinclude GoZero-request.msg.html

(cl:defclass <GoZero-request> (roslisp-msg-protocol:ros-message)
  ((confirm
    :reader confirm
    :initarg :confirm
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass GoZero-request (<GoZero-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <GoZero-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'GoZero-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<GoZero-request> is deprecated: use lwh_so101_real-srv:GoZero-request instead.")))

(cl:ensure-generic-function 'confirm-val :lambda-list '(m))
(cl:defmethod confirm-val ((m <GoZero-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:confirm-val is deprecated.  Use lwh_so101_real-srv:confirm instead.")
  (confirm m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <GoZero-request>) ostream)
  "Serializes a message object of type '<GoZero-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'confirm) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <GoZero-request>) istream)
  "Deserializes a message object of type '<GoZero-request>"
    (cl:setf (cl:slot-value msg 'confirm) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<GoZero-request>)))
  "Returns string type for a service object of type '<GoZero-request>"
  "lwh_so101_real/GoZeroRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GoZero-request)))
  "Returns string type for a service object of type 'GoZero-request"
  "lwh_so101_real/GoZeroRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<GoZero-request>)))
  "Returns md5sum for a message object of type '<GoZero-request>"
  "afbed5da1b16c7ab8a2d82fcdedd5932")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'GoZero-request)))
  "Returns md5sum for a message object of type 'GoZero-request"
  "afbed5da1b16c7ab8a2d82fcdedd5932")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<GoZero-request>)))
  "Returns full string definition for message of type '<GoZero-request>"
  (cl:format cl:nil "bool confirm~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'GoZero-request)))
  "Returns full string definition for message of type 'GoZero-request"
  (cl:format cl:nil "bool confirm~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <GoZero-request>))
  (cl:+ 0
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <GoZero-request>))
  "Converts a ROS message object to a list"
  (cl:list 'GoZero-request
    (cl:cons ':confirm (confirm msg))
))
;//! \htmlinclude GoZero-response.msg.html

(cl:defclass <GoZero-response> (roslisp-msg-protocol:ros-message)
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

(cl:defclass GoZero-response (<GoZero-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <GoZero-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'GoZero-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<GoZero-response> is deprecated: use lwh_so101_real-srv:GoZero-response instead.")))

(cl:ensure-generic-function 'status-val :lambda-list '(m))
(cl:defmethod status-val ((m <GoZero-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:status-val is deprecated.  Use lwh_so101_real-srv:status instead.")
  (status m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <GoZero-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:message-val is deprecated.  Use lwh_so101_real-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <GoZero-response>) ostream)
  "Serializes a message object of type '<GoZero-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'status) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <GoZero-response>) istream)
  "Deserializes a message object of type '<GoZero-response>"
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<GoZero-response>)))
  "Returns string type for a service object of type '<GoZero-response>"
  "lwh_so101_real/GoZeroResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GoZero-response)))
  "Returns string type for a service object of type 'GoZero-response"
  "lwh_so101_real/GoZeroResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<GoZero-response>)))
  "Returns md5sum for a message object of type '<GoZero-response>"
  "afbed5da1b16c7ab8a2d82fcdedd5932")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'GoZero-response)))
  "Returns md5sum for a message object of type 'GoZero-response"
  "afbed5da1b16c7ab8a2d82fcdedd5932")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<GoZero-response>)))
  "Returns full string definition for message of type '<GoZero-response>"
  (cl:format cl:nil "bool status~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'GoZero-response)))
  "Returns full string definition for message of type 'GoZero-response"
  (cl:format cl:nil "bool status~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <GoZero-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <GoZero-response>))
  "Converts a ROS message object to a list"
  (cl:list 'GoZero-response
    (cl:cons ':status (status msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'GoZero)))
  'GoZero-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'GoZero)))
  'GoZero-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'GoZero)))
  "Returns string type for a service object of type '<GoZero>"
  "lwh_so101_real/GoZero")