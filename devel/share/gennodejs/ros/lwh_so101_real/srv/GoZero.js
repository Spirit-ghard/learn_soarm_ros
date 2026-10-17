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

class GoZeroRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.confirm = null;
    }
    else {
      if (initObj.hasOwnProperty('confirm')) {
        this.confirm = initObj.confirm
      }
      else {
        this.confirm = false;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type GoZeroRequest
    // Serialize message field [confirm]
    bufferOffset = _serializer.bool(obj.confirm, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GoZeroRequest
    let len;
    let data = new GoZeroRequest(null);
    // Deserialize message field [confirm]
    data.confirm = _deserializer.bool(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 1;
  }

  static datatype() {
    // Returns string type for a service object
    return 'lwh_so101_real/GoZeroRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'b37994baa157ef8535427a2de0e06206';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool confirm
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new GoZeroRequest(null);
    if (msg.confirm !== undefined) {
      resolved.confirm = msg.confirm;
    }
    else {
      resolved.confirm = false
    }

    return resolved;
    }
};

class GoZeroResponse {
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
    // Serializes a message object of type GoZeroResponse
    // Serialize message field [status]
    bufferOffset = _serializer.bool(obj.status, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type GoZeroResponse
    let len;
    let data = new GoZeroResponse(null);
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
    return 'lwh_so101_real/GoZeroResponse';
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
    const resolved = new GoZeroResponse(null);
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
  Request: GoZeroRequest,
  Response: GoZeroResponse,
  md5sum() { return 'afbed5da1b16c7ab8a2d82fcdedd5932'; },
  datatype() { return 'lwh_so101_real/GoZero'; }
};
