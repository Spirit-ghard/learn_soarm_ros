// Auto-generated. Do not edit!

// (in-package lwh_so101_real.msg)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;
let std_msgs = _finder('std_msgs');

//-----------------------------------------------------------

class SO101Status {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.header = null;
      this.connected = null;
      this.torque_enabled = null;
      this.read_only = null;
      this.command_blocked = null;
      this.port = null;
      this.message = null;
    }
    else {
      if (initObj.hasOwnProperty('header')) {
        this.header = initObj.header
      }
      else {
        this.header = new std_msgs.msg.Header();
      }
      if (initObj.hasOwnProperty('connected')) {
        this.connected = initObj.connected
      }
      else {
        this.connected = false;
      }
      if (initObj.hasOwnProperty('torque_enabled')) {
        this.torque_enabled = initObj.torque_enabled
      }
      else {
        this.torque_enabled = false;
      }
      if (initObj.hasOwnProperty('read_only')) {
        this.read_only = initObj.read_only
      }
      else {
        this.read_only = false;
      }
      if (initObj.hasOwnProperty('command_blocked')) {
        this.command_blocked = initObj.command_blocked
      }
      else {
        this.command_blocked = false;
      }
      if (initObj.hasOwnProperty('port')) {
        this.port = initObj.port
      }
      else {
        this.port = '';
      }
      if (initObj.hasOwnProperty('message')) {
        this.message = initObj.message
      }
      else {
        this.message = '';
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type SO101Status
    // Serialize message field [header]
    bufferOffset = std_msgs.msg.Header.serialize(obj.header, buffer, bufferOffset);
    // Serialize message field [connected]
    bufferOffset = _serializer.bool(obj.connected, buffer, bufferOffset);
    // Serialize message field [torque_enabled]
    bufferOffset = _serializer.bool(obj.torque_enabled, buffer, bufferOffset);
    // Serialize message field [read_only]
    bufferOffset = _serializer.bool(obj.read_only, buffer, bufferOffset);
    // Serialize message field [command_blocked]
    bufferOffset = _serializer.bool(obj.command_blocked, buffer, bufferOffset);
    // Serialize message field [port]
    bufferOffset = _serializer.string(obj.port, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type SO101Status
    let len;
    let data = new SO101Status(null);
    // Deserialize message field [header]
    data.header = std_msgs.msg.Header.deserialize(buffer, bufferOffset);
    // Deserialize message field [connected]
    data.connected = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [torque_enabled]
    data.torque_enabled = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [read_only]
    data.read_only = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [command_blocked]
    data.command_blocked = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [port]
    data.port = _deserializer.string(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += std_msgs.msg.Header.getMessageSize(object.header);
    length += _getByteLength(object.port);
    length += _getByteLength(object.message);
    return length + 12;
  }

  static datatype() {
    // Returns string type for a message object
    return 'lwh_so101_real/SO101Status';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'c33d318113afe8fe8fae361a1d7da675';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    std_msgs/Header header
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
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new SO101Status(null);
    if (msg.header !== undefined) {
      resolved.header = std_msgs.msg.Header.Resolve(msg.header)
    }
    else {
      resolved.header = new std_msgs.msg.Header()
    }

    if (msg.connected !== undefined) {
      resolved.connected = msg.connected;
    }
    else {
      resolved.connected = false
    }

    if (msg.torque_enabled !== undefined) {
      resolved.torque_enabled = msg.torque_enabled;
    }
    else {
      resolved.torque_enabled = false
    }

    if (msg.read_only !== undefined) {
      resolved.read_only = msg.read_only;
    }
    else {
      resolved.read_only = false
    }

    if (msg.command_blocked !== undefined) {
      resolved.command_blocked = msg.command_blocked;
    }
    else {
      resolved.command_blocked = false
    }

    if (msg.port !== undefined) {
      resolved.port = msg.port;
    }
    else {
      resolved.port = ''
    }

    if (msg.message !== undefined) {
      resolved.message = msg.message;
    }
    else {
      resolved.message = ''
    }

    return resolved;
    }
};

module.exports = SO101Status;
