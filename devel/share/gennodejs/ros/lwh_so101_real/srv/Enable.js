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

class EnableRequest {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.enable_request = null;
    }
    else {
      if (initObj.hasOwnProperty('enable_request')) {
        this.enable_request = initObj.enable_request
      }
      else {
        this.enable_request = false;
      }
    }
  }

  static serialize(obj, buffer, bufferOffset) {
    // Serializes a message object of type EnableRequest
    // Serialize message field [enable_request]
    bufferOffset = _serializer.bool(obj.enable_request, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type EnableRequest
    let len;
    let data = new EnableRequest(null);
    // Deserialize message field [enable_request]
    data.enable_request = _deserializer.bool(buffer, bufferOffset);
    return data;
  }

  static getMessageSize(object) {
    return 1;
  }

  static datatype() {
    // Returns string type for a service object
    return 'lwh_so101_real/EnableRequest';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return 'e4d2a33bd24e85ccd5f8fbef5fbeeb5f';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool enable_request
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new EnableRequest(null);
    if (msg.enable_request !== undefined) {
      resolved.enable_request = msg.enable_request;
    }
    else {
      resolved.enable_request = false
    }

    return resolved;
    }
};

class EnableResponse {
  constructor(initObj={}) {
    if (initObj === null) {
      // initObj === null is a special case for deserialization where we don't initialize fields
      this.enable_response = null;
      this.message = null;
    }
    else {
      if (initObj.hasOwnProperty('enable_response')) {
        this.enable_response = initObj.enable_response
      }
      else {
        this.enable_response = false;
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
    // Serializes a message object of type EnableResponse
    // Serialize message field [enable_response]
    bufferOffset = _serializer.bool(obj.enable_response, buffer, bufferOffset);
    // Serialize message field [message]
    bufferOffset = _serializer.string(obj.message, buffer, bufferOffset);
    return bufferOffset;
  }

  static deserialize(buffer, bufferOffset=[0]) {
    //deserializes a message object of type EnableResponse
    let len;
    let data = new EnableResponse(null);
    // Deserialize message field [enable_response]
    data.enable_response = _deserializer.bool(buffer, bufferOffset);
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
    return 'lwh_so101_real/EnableResponse';
  }

  static md5sum() {
    //Returns md5sum for a message object
    return '640d1bf265a1e5ab5371d8e40612baf0';
  }

  static messageDefinition() {
    // Returns full string definition for message
    return `
    bool enable_response
    string message
    
    
    `;
  }

  static Resolve(msg) {
    // deep-construct a valid message object instance of whatever was passed in
    if (typeof msg !== 'object' || msg === null) {
      msg = {};
    }
    const resolved = new EnableResponse(null);
    if (msg.enable_response !== undefined) {
      resolved.enable_response = msg.enable_response;
    }
    else {
      resolved.enable_response = false
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
  Request: EnableRequest,
  Response: EnableResponse,
  md5sum() { return '94311001937e1d83c38bf078453474ea'; },
  datatype() { return 'lwh_so101_real/Enable'; }
};
