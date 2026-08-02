; Auto-generated. Do not edit!


(cl:in-package lwh_so101_real-srv)


;//! \htmlinclude Enable-request.msg.html

(cl:defclass <Enable-request> (roslisp-msg-protocol:ros-message)
  ((enable_request
    :reader enable_request
    :initarg :enable_request
    :type cl:boolean
    :initform cl:nil))
)

(cl:defclass Enable-request (<Enable-request>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Enable-request>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Enable-request)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<Enable-request> is deprecated: use lwh_so101_real-srv:Enable-request instead.")))

(cl:ensure-generic-function 'enable_request-val :lambda-list '(m))
(cl:defmethod enable_request-val ((m <Enable-request>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:enable_request-val is deprecated.  Use lwh_so101_real-srv:enable_request instead.")
  (enable_request m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Enable-request>) ostream)
  "Serializes a message object of type '<Enable-request>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'enable_request) 1 0)) ostream)
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Enable-request>) istream)
  "Deserializes a message object of type '<Enable-request>"
    (cl:setf (cl:slot-value msg 'enable_request) (cl:not (cl:zerop (cl:read-byte istream))))
  msg
)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Enable-request>)))
  "Returns string type for a service object of type '<Enable-request>"
  "lwh_so101_real/EnableRequest")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Enable-request)))
  "Returns string type for a service object of type 'Enable-request"
  "lwh_so101_real/EnableRequest")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Enable-request>)))
  "Returns md5sum for a message object of type '<Enable-request>"
  "94311001937e1d83c38bf078453474ea")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Enable-request)))
  "Returns md5sum for a message object of type 'Enable-request"
  "94311001937e1d83c38bf078453474ea")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Enable-request>)))
  "Returns full string definition for message of type '<Enable-request>"
  (cl:format cl:nil "bool enable_request~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Enable-request)))
  "Returns full string definition for message of type 'Enable-request"
  (cl:format cl:nil "bool enable_request~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Enable-request>))
  (cl:+ 0
     1
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Enable-request>))
  "Converts a ROS message object to a list"
  (cl:list 'Enable-request
    (cl:cons ':enable_request (enable_request msg))
))
;//! \htmlinclude Enable-response.msg.html

(cl:defclass <Enable-response> (roslisp-msg-protocol:ros-message)
  ((enable_response
    :reader enable_response
    :initarg :enable_response
    :type cl:boolean
    :initform cl:nil)
   (message
    :reader message
    :initarg :message
    :type cl:string
    :initform ""))
)

(cl:defclass Enable-response (<Enable-response>)
  ())

(cl:defmethod cl:initialize-instance :after ((m <Enable-response>) cl:&rest args)
  (cl:declare (cl:ignorable args))
  (cl:unless (cl:typep m 'Enable-response)
    (roslisp-msg-protocol:msg-deprecation-warning "using old message class name lwh_so101_real-srv:<Enable-response> is deprecated: use lwh_so101_real-srv:Enable-response instead.")))

(cl:ensure-generic-function 'enable_response-val :lambda-list '(m))
(cl:defmethod enable_response-val ((m <Enable-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:enable_response-val is deprecated.  Use lwh_so101_real-srv:enable_response instead.")
  (enable_response m))

(cl:ensure-generic-function 'message-val :lambda-list '(m))
(cl:defmethod message-val ((m <Enable-response>))
  (roslisp-msg-protocol:msg-deprecation-warning "Using old-style slot reader lwh_so101_real-srv:message-val is deprecated.  Use lwh_so101_real-srv:message instead.")
  (message m))
(cl:defmethod roslisp-msg-protocol:serialize ((msg <Enable-response>) ostream)
  "Serializes a message object of type '<Enable-response>"
  (cl:write-byte (cl:ldb (cl:byte 8 0) (cl:if (cl:slot-value msg 'enable_response) 1 0)) ostream)
  (cl:let ((__ros_str_len (cl:length (cl:slot-value msg 'message))))
    (cl:write-byte (cl:ldb (cl:byte 8 0) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 8) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 16) __ros_str_len) ostream)
    (cl:write-byte (cl:ldb (cl:byte 8 24) __ros_str_len) ostream))
  (cl:map cl:nil #'(cl:lambda (c) (cl:write-byte (cl:char-code c) ostream)) (cl:slot-value msg 'message))
)
(cl:defmethod roslisp-msg-protocol:deserialize ((msg <Enable-response>) istream)
  "Deserializes a message object of type '<Enable-response>"
    (cl:setf (cl:slot-value msg 'enable_response) (cl:not (cl:zerop (cl:read-byte istream))))
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
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql '<Enable-response>)))
  "Returns string type for a service object of type '<Enable-response>"
  "lwh_so101_real/EnableResponse")
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Enable-response)))
  "Returns string type for a service object of type 'Enable-response"
  "lwh_so101_real/EnableResponse")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql '<Enable-response>)))
  "Returns md5sum for a message object of type '<Enable-response>"
  "94311001937e1d83c38bf078453474ea")
(cl:defmethod roslisp-msg-protocol:md5sum ((type (cl:eql 'Enable-response)))
  "Returns md5sum for a message object of type 'Enable-response"
  "94311001937e1d83c38bf078453474ea")
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql '<Enable-response>)))
  "Returns full string definition for message of type '<Enable-response>"
  (cl:format cl:nil "bool enable_response~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:message-definition ((type (cl:eql 'Enable-response)))
  "Returns full string definition for message of type 'Enable-response"
  (cl:format cl:nil "bool enable_response~%string message~%~%~%~%"))
(cl:defmethod roslisp-msg-protocol:serialization-length ((msg <Enable-response>))
  (cl:+ 0
     1
     4 (cl:length (cl:slot-value msg 'message))
))
(cl:defmethod roslisp-msg-protocol:ros-message-to-list ((msg <Enable-response>))
  "Converts a ROS message object to a list"
  (cl:list 'Enable-response
    (cl:cons ':enable_response (enable_response msg))
    (cl:cons ':message (message msg))
))
(cl:defmethod roslisp-msg-protocol:service-request-type ((msg (cl:eql 'Enable)))
  'Enable-request)
(cl:defmethod roslisp-msg-protocol:service-response-type ((msg (cl:eql 'Enable)))
  'Enable-response)
(cl:defmethod roslisp-msg-protocol:ros-datatype ((msg (cl:eql 'Enable)))
  "Returns string type for a service object of type '<Enable>"
  "lwh_so101_real/Enable")