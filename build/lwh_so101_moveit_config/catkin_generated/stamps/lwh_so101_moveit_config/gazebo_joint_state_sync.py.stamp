#!/usr/bin/env python3
"""Spawn URDF visual meshes in Gazebo and drive them from robot TF.

The SO101 CAD URDF is good for RViz/MoveIt, but its current Gazebo dynamics are
not stable enough for ros_control. This node keeps Gazebo as a visual companion:
each URDF link visual is spawned as an independent Gazebo model, then its pose is
updated from robot_state_publisher TF whenever MoveIt fake execution changes.
"""

import html
import os
import re
import xml.etree.ElementTree as ET

import rospkg
import rospy
import tf2_ros
from gazebo_msgs.msg import ModelState
from gazebo_msgs.srv import DeleteModel, GetWorldProperties, SetModelState, SpawnModel
from geometry_msgs.msg import Pose
from sensor_msgs.msg import JointState


PACKAGE_URI_RE = re.compile(r"^package://([^/]+)/(.+)$")


class GazeboJointStateSync:
    def __init__(self):
        self.model_prefix = rospy.get_param("~model_name", "so101")
        self.tf_root_frame = rospy.get_param("~tf_root_frame", "dummy_link")
        self.gazebo_reference_frame = rospy.get_param("~gazebo_reference_frame", "world")
        self.source_topic = rospy.get_param("~source_topic", "/move_group/fake_controller_joint_states")
        self.rate = float(rospy.get_param("~rate", 30.0))

        self._rospack = rospkg.RosPack()
        self._visual_models = self._load_visual_models()
        self._dirty = True

        self._tf_buffer = tf2_ros.Buffer(cache_time=rospy.Duration(5.0))
        self._tf_listener = tf2_ros.TransformListener(self._tf_buffer)

        rospy.loginfo("Waiting for Gazebo visual model services")
        rospy.wait_for_service("/gazebo/spawn_sdf_model")
        rospy.wait_for_service("/gazebo/delete_model")
        rospy.wait_for_service("/gazebo/set_model_state")
        rospy.wait_for_service("/gazebo/get_world_properties")
        self._spawn_model = rospy.ServiceProxy("/gazebo/spawn_sdf_model", SpawnModel)
        self._delete_model = rospy.ServiceProxy("/gazebo/delete_model", DeleteModel)
        self._set_model_state = rospy.ServiceProxy("/gazebo/set_model_state", SetModelState)
        self._get_world_properties = rospy.ServiceProxy("/gazebo/get_world_properties", GetWorldProperties)

        self._spawn_visual_models()

        self._joint_sub = rospy.Subscriber(self.source_topic, JointState, self._on_joint_state, queue_size=1)
        self._timer = rospy.Timer(rospy.Duration(1.0 / self.rate), self._sync_models)
        rospy.loginfo(
            "Gazebo visual sync ready: %d link models follow %s",
            len(self._visual_models),
            self.source_topic,
        )

    def _load_visual_models(self):
        robot_xml = rospy.get_param("/robot_description")
        root = ET.fromstring(robot_xml)
        materials = self._read_materials(root)
        visual_models = []

        for link in root.findall("link"):
            link_name = link.get("name")
            visuals = []
            for index, visual in enumerate(link.findall("visual")):
                mesh = visual.find("geometry/mesh")
                if mesh is None:
                    continue
                filename = mesh.get("filename")
                if not filename:
                    continue

                origin = visual.find("origin")
                material = visual.find("material")
                material_name = material.get("name") if material is not None else None
                color = materials.get(material_name, "0.8 0.8 0.8 1")
                visuals.append(
                    {
                        "name": f"visual_{index}",
                        "pose": self._origin_to_pose(origin),
                        "mesh": self._resolve_mesh_uri(filename),
                        "scale": mesh.get("scale", "1 1 1"),
                        "color": color,
                    }
                )

            if visuals:
                visual_models.append(
                    {
                        "link": link_name,
                        "model": f"{self.model_prefix}_visual_{link_name}",
                        "visuals": visuals,
                    }
                )

        if not visual_models:
            raise RuntimeError("No mesh visuals were found in /robot_description")
        return visual_models

    @staticmethod
    def _read_materials(root):
        materials = {}
        for material in root.findall("material"):
            name = material.get("name")
            color = material.find("color")
            if name and color is not None and color.get("rgba"):
                materials[name] = color.get("rgba")
        return materials

    @staticmethod
    def _origin_to_pose(origin):
        xyz = "0 0 0"
        rpy = "0 0 0"
        if origin is not None:
            xyz = origin.get("xyz", xyz)
            rpy = origin.get("rpy", rpy)
        return f"{xyz} {rpy}"

    def _resolve_mesh_uri(self, uri):
        match = PACKAGE_URI_RE.match(uri)
        if not match:
            return uri
        package_name, relative_path = match.groups()
        package_path = self._rospack.get_path(package_name)
        return "file://" + os.path.join(package_path, relative_path)

    def _spawn_visual_models(self):
        existing_models = set()
        try:
            existing_models = set(self._get_world_properties().model_names)
        except rospy.ServiceException as exc:
            rospy.logwarn("Could not query existing Gazebo models before spawn: %s", exc)

        for visual_model in self._visual_models:
            model_name = visual_model["model"]
            if model_name in existing_models:
                response = self._delete_model(model_name)
                if not response.success:
                    rospy.logwarn("Could not delete old Gazebo visual model %s: %s", model_name, response.status_message)

            sdf = self._build_sdf_model(model_name, visual_model["visuals"])
            response = self._spawn_model(model_name, sdf, "", Pose(), self.gazebo_reference_frame)
            if not response.success:
                raise RuntimeError(f"Failed to spawn Gazebo visual model {model_name}: {response.status_message}")

    def _build_sdf_model(self, model_name, visuals):
        visual_xml = "\n".join(self._build_sdf_visual(visual) for visual in visuals)
        return f"""<?xml version="1.0"?>
<sdf version="1.6">
  <model name="{html.escape(model_name)}">
    <static>false</static>
    <link name="link">
      <gravity>false</gravity>
      <kinematic>true</kinematic>
      <inertial>
        <mass>0.001</mass>
        <inertia>
          <ixx>1e-6</ixx><ixy>0</ixy><ixz>0</ixz>
          <iyy>1e-6</iyy><iyz>0</iyz><izz>1e-6</izz>
        </inertia>
      </inertial>
{visual_xml}
    </link>
  </model>
</sdf>
"""

    @staticmethod
    def _build_sdf_visual(visual):
        color = html.escape(visual["color"])
        mesh = html.escape(visual["mesh"])
        scale = html.escape(visual["scale"])
        pose = html.escape(visual["pose"])
        name = html.escape(visual["name"])
        return f"""      <visual name="{name}">
        <pose>{pose}</pose>
        <geometry>
          <mesh>
            <uri>{mesh}</uri>
            <scale>{scale}</scale>
          </mesh>
        </geometry>
        <material>
          <ambient>{color}</ambient>
          <diffuse>{color}</diffuse>
        </material>
      </visual>"""

    def _on_joint_state(self, _msg):
        self._dirty = True

    def _sync_models(self, _event):
        if not self._dirty:
            return
        self._dirty = False

        for visual_model in self._visual_models:
            link_name = visual_model["link"]
            try:
                transform = self._tf_buffer.lookup_transform(
                    self.tf_root_frame,
                    link_name,
                    rospy.Time(0),
                    rospy.Duration(0.01),
                )
            except (tf2_ros.LookupException, tf2_ros.ConnectivityException, tf2_ros.ExtrapolationException):
                self._dirty = True
                continue

            model_state = ModelState()
            model_state.model_name = visual_model["model"]
            model_state.reference_frame = self.gazebo_reference_frame
            model_state.pose.position.x = transform.transform.translation.x
            model_state.pose.position.y = transform.transform.translation.y
            model_state.pose.position.z = transform.transform.translation.z
            model_state.pose.orientation = transform.transform.rotation

            try:
                response = self._set_model_state(model_state)
                if not response.success:
                    rospy.logwarn_throttle(2.0, "Gazebo visual sync rejected: %s", response.status_message)
            except rospy.ServiceException as exc:
                rospy.logwarn_throttle(2.0, "Gazebo visual sync failed: %s", exc)


def main():
    rospy.init_node("gazebo_joint_state_sync")
    GazeboJointStateSync()
    rospy.spin()


if __name__ == "__main__":
    main()
