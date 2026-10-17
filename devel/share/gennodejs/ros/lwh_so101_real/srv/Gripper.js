// Auto-generated. Do not edit!

// (in-package lwh_so101_real.srv)


"use strict";

const _serializer = _ros_msg_utils.Serialize;
const _arraySerializer = _serializer.Array;
const _deserializer = _ros_msg_utils.Deserialize;
const _arrayDeserializer = _deserializer.Array;
const _finder = _ros_msg_utils.Find;
const _getByteLength = _ros_msg_utils.getByteLength;

//-----------------------------------------------------------


//-----------------------------------------------------------

class GripperRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.gripper_position = null;
    }
    else {
      if (initObj.hasOwnProperty('gripper_position')) {
        this.gripper_position = initObj.gripper_position
      }
      else {
        this.gripper_position = 0.0;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type GripperRequest
    // Serialize message field [gripper_position]
    bufferOffset = _serializer.float64(obj.gripper_position, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GripperRequest
    let len;
    let data = new GripperRequest(null);
    // Deserialize message field [gripper_position]
    data.gripper_position = _deserializer.float64(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 8;
  }

  static datatype() {
    // Returns string type for a service object
    return 'lwh_so101_real/GripperRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'd39d8fda09ea3be5be8a1c26520c3ffa';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    float64 gripper_position
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new GripperRequest(null);
    if (msg.gripper_position !== undefined) {
      resolved.gripper_position = msg.gripper_position;
    }
    else {
      resolved.gripper_position = 0.0
    }

    return resolved;
    }
};

class GripperResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.status = null;
      this.message = null;
    }
    else {
      if (initObj.hasOwnProperty('status')) {
        this.status = initObj.status
      }
      else {
        this.status = false;
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
    // Serializes a message object of type GripperResponse
    // Serialize message field [status]
    bufferOffset = _serializer.bool(obj.status, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GripperResponse
    let len;
    let data = new GripperResponse(null);
    // Deserialize message field [status]
    data.status = _deserializer.bool(buffer, bufferOffset);
    // Deserialize message field [message]
    data.message = _deserializer.string(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    let length = 0;
    length += _getByteLength(object.message);
    return length + 5;
  }

  static datatype() {
    // Returns string type for a service object
    return 'lwh_so101_real/GripperResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'cc9c64df4628f5bb500ddeb635768626';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool status
    string message
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new GripperResponse(null);
    if (msg.status !== undefined) {
      resolved.status = msg.status;
    }
    else {
      resolved.status = false
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

module.exports = {
  Request: GripperRequest,
  Response: GripperResponse,
  md5sum() { return '24faaffe681998cb080d78f790b7098c'; },
  datatype() { return 'lwh_so101_real/Gripper'; }
};
