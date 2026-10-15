#!/usr/bin/env python3
"""Small MoveIt joint-space control panel for the SO101 fake robot."""

import math
import signal
import sys
import threading

import moveit_commander
import rospy
from PyQt5.QtCore import Qt, QTimer, pyqtSignal
from PyQt5.QtWidgets import (
    QApplication,
    QFrame,
    QGridLayout,
    QHBoxLayout,
    QLabel,
    QMainWindow,
    QPushButton,
    QSlider,
    QVBoxLayout,
    QWidget,
)


ARM_JOINTS = [
    "shoulder_pan",
    "shoulder_lift",
    "elbow_flex",
    "wrist_flex",
    "wrist_roll",
]

JOINT_LIMITS_DEG = {
    "shoulder_pan": (-110.0, 110.0),
    "shoulder_lift": (-100.0, 100.0),
    "elbow_flex": (-96.8, 96.8),
    "wrist_flex": (-95.0, 95.0),
    "wrist_roll": (-157.2, 162.8),
}

READY_DEG = {
    "shoulder_pan": 0.0,
    "shoulder_lift": -31.5,
    "elbow_flex": 45.8,
    "wrist_flex": -14.3,
    "wrist_roll": 0.0,
}

SCALE = 10


def rad_to_deg(value):
    return value * 180.0 / math.pi


def deg_to_rad(value):
    return value * math.pi / 180.0


class SO101MoveItWindow(QMainWindow):
    status_requested = pyqtSignal(str)
    refresh_requested = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._closing = False
        self._executing = False
        self._syncing = False
        self._lock = threading.RLock()

        moveit_commander.roscpp_initialize(sys.argv)
        rospy.init_node("so101_moveit_joint_gui", anonymous=True, disable_signals=True)

        self.arm = moveit_commander.MoveGroupCommander("arm")
        self.arm.set_planning_time(float(rospy.get_param("~planning_time", 2.0)))
        self.arm.set_max_velocity_scaling_factor(float(rospy.get_param("~velocity_scale", 0.35)))
        self.arm.set_max_acceleration_scaling_factor(float(rospy.get_param("~acceleration_scale", 0.35)))

        self.sliders = {}
        self.target_labels = {}
        self.current_labels = {}

        self._build_ui()
        self.status_requested.connect(self.status_label.setText)
        self.refresh_requested.connect(self._refresh_current_labels)
        self._set_sliders_from_current()

        self.refresh_timer = QTimer(self)
        self.refresh_timer.timeout.connect(self._refresh_current_labels)
        self.refresh_timer.start(250)

    def _build_ui(self):
        self.setWindowTitle("SO101 MoveIt 控制")
        self.resize(720, 470)

        root = QWidget()
        root.setObjectName("root")
        layout = QVBoxLayout(root)
        layout.setContentsMargins(22, 22, 22, 22)
        layout.setSpacing(16)
        self.setCentralWidget(root)

        header = QHBoxLayout()
        title_box = QVBoxLayout()
        title = QLabel("SO101 MoveIt 控制")
        title.setObjectName("title")
        subtitle = QLabel("只控制 MoveIt fake 模型，不连接真实机械臂")
        subtitle.setObjectName("subtitle")
        title_box.addWidget(title)
        title_box.addWidget(subtitle)
        header.addLayout(title_box, 1)

        self.badge = QLabel("fake")
        self.badge.setObjectName("badge")
        header.addWidget(self.badge, 0, Qt.AlignRight | Qt.AlignTop)
        layout.addLayout(header)

        buttons = QHBoxLayout()
        self.execute_button = QPushButton("执行目标")
        self.execute_button.setObjectName("primaryButton")
        self.zero_button = QPushButton("零位")
        self.zero_button.setObjectName("secondaryButton")
        self.ready_button = QPushButton("预备位")
        self.ready_button.setObjectName("secondaryButton")
        self.sync_button = QPushButton("同步当前")
        self.sync_button.setObjectName("secondaryButton")

        self.execute_button.clicked.connect(self._execute_from_sliders)
        self.zero_button.clicked.connect(self._set_zero)
        self.ready_button.clicked.connect(self._set_ready)
        self.sync_button.clicked.connect(self._set_sliders_from_current)

        buttons.addWidget(self.execute_button)
        buttons.addWidget(self.zero_button)
        buttons.addWidget(self.ready_button)
        buttons.addWidget(self.sync_button)
        buttons.addStretch(1)
        layout.addLayout(buttons)

        card = QFrame()
        card.setObjectName("card")
        grid = QGridLayout(card)
        grid.setContentsMargins(18, 16, 18, 16)
        grid.setHorizontalSpacing(14)
        grid.setVerticalSpacing(12)
        grid.setColumnStretch(1, 1)

        grid.addWidget(self._head("joint"), 0, 0)
        grid.addWidget(self._head("target"), 0, 1)
        grid.addWidget(self._head("目标角度"), 0, 2)
        grid.addWidget(self._head("当前角度"), 0, 3)

        for row, name in enumerate(ARM_JOINTS, start=1):
            lower, upper = JOINT_LIMITS_DEG[name]
            name_label = QLabel(name)
            name_label.setObjectName("jointName")

            slider = QSlider(Qt.Horizontal)
            slider.setMinimum(round(lower * SCALE))
            slider.setMaximum(round(upper * SCALE))
            slider.setSingleStep(1)
            slider.setPageStep(10)
            slider.valueChanged.connect(self._update_target_labels)
            slider.sliderReleased.connect(self._execute_from_sliders)

            target_label = QLabel("-- deg")
            target_label.setObjectName("value")
            target_label.setAlignment(Qt.AlignRight | Qt.AlignVCenter)

            current_label = QLabel("-- deg")
            current_label.setObjectName("current")
            current_label.setAlignment(Qt.AlignRight | Qt.AlignVCenter)

            grid.addWidget(name_label, row, 0)
            grid.addWidget(slider, row, 1)
            grid.addWidget(target_label, row, 2)
            grid.addWidget(current_label, row, 3)

            self.sliders[name] = slider
            self.target_labels[name] = target_label
            self.current_labels[name] = current_label

        layout.addWidget(card)

        self.status_label = QLabel("等待 MoveIt")
        self.status_label.setObjectName("status")
        layout.addWidget(self.status_label)

        self.setStyleSheet(
            """
            QWidget#root {
                background: #f3f6fb;
                color: #182230;
                font-family: "Noto Sans CJK SC", "Microsoft YaHei", "Sans";
                font-size: 14px;
            }
            QLabel#title {
                font-size: 24px;
                font-weight: 700;
                color: #101828;
            }
            QLabel#subtitle {
                color: #667085;
                font-size: 13px;
                margin-top: 4px;
            }
            QLabel#badge {
                background: #eff4ff;
                color: #1849a9;
                border-radius: 14px;
                padding: 6px 13px;
                font-weight: 700;
            }
            QPushButton {
                min-height: 34px;
                border-radius: 7px;
                padding: 0 16px;
                font-weight: 700;
            }
            QPushButton#primaryButton {
                background: #155eef;
                color: white;
                border: 1px solid #155eef;
            }
            QPushButton#primaryButton:hover {
                background: #004eeb;
            }
            QPushButton#secondaryButton {
                background: white;
                color: #344054;
                border: 1px solid #d0d5dd;
            }
            QPushButton#secondaryButton:hover {
                background: #f9fafb;
            }
            QFrame#card {
                background: white;
                border: 1px solid #d8dee8;
                border-radius: 8px;
            }
            QLabel#head {
                color: #667085;
                font-size: 12px;
                font-weight: 700;
            }
            QLabel#jointName {
                color: #101828;
                font-weight: 700;
                min-width: 92px;
            }
            QLabel#value, QLabel#current {
                color: #344054;
                min-width: 78px;
            }
            QLabel#status {
                color: #475467;
                background: #ffffff;
                border: 1px solid #d8dee8;
                border-radius: 8px;
                padding: 10px 12px;
            }
            QSlider::groove:horizontal {
                height: 8px;
                background: #e4e7ec;
                border-radius: 4px;
            }
            QSlider::sub-page:horizontal {
                background: #155eef;
                border-radius: 4px;
            }
            QSlider::handle:horizontal {
                background: white;
                width: 18px;
                height: 18px;
                margin: -6px 0;
                border-radius: 9px;
                border: 2px solid #155eef;
            }
            """
        )

    def _head(self, text):
        label = QLabel(text)
        label.setObjectName("head")
        return label

    def _get_current_deg(self):
        values = self.arm.get_current_joint_values()
        return {name: rad_to_deg(values[index]) for index, name in enumerate(ARM_JOINTS)}

    def _set_sliders_from_current(self):
        with self._lock:
            self._syncing = True
            try:
                current = self._get_current_deg()
                for name, value in current.items():
                    self.sliders[name].setValue(round(value * SCALE))
                self.status_label.setText("已同步当前 MoveIt 姿态")
            finally:
                self._syncing = False
        self._update_target_labels()
        self._refresh_current_labels()

    def _set_zero(self):
        self._set_target_degrees({name: 0.0 for name in ARM_JOINTS})
        self._execute_from_sliders()

    def _set_ready(self):
        self._set_target_degrees(READY_DEG)
        self._execute_from_sliders()

    def _set_target_degrees(self, targets):
        self._syncing = True
        try:
            for name, value in targets.items():
                self.sliders[name].setValue(round(value * SCALE))
        finally:
            self._syncing = False
        self._update_target_labels()

    def _target_radians(self):
        return [deg_to_rad(self.sliders[name].value() / SCALE) for name in ARM_JOINTS]

    def _update_target_labels(self):
        for name in ARM_JOINTS:
            value = self.sliders[name].value() / SCALE
            self.target_labels[name].setText(f"{value:+.1f} deg")

    def _refresh_current_labels(self):
        if self._closing or self._executing or rospy.is_shutdown():
            return
        try:
            current = self._get_current_deg()
        except Exception as exc:
            self.status_label.setText(f"等待 MoveIt: {exc}")
            return
        for name, value in current.items():
            self.current_labels[name].setText(f"{value:+.1f} deg")

    def _execute_from_sliders(self):
        if self._syncing or self._executing:
            return
        threading.Thread(target=self._execute_worker, daemon=True).start()

    def _execute_worker(self):
        self._executing = True
        self.status_requested.emit("正在规划并执行")
        try:
            self.arm.set_joint_value_target(self._target_radians())
            ok = self.arm.go(wait=True)
            self.arm.stop()
            if ok:
                self.status_requested.emit("执行完成，RViz 模型已更新")
            else:
                self.status_requested.emit("执行失败，目标可能超限或当前状态无效")
        except Exception as exc:
            self.status_requested.emit(f"执行失败: {exc}")
        finally:
            self._executing = False
            self.refresh_requested.emit()

    def closeEvent(self, event):
        self._closing = True
        if hasattr(self, "refresh_timer"):
            self.refresh_timer.stop()
        moveit_commander.roscpp_shutdown()
        super().closeEvent(event)


def main():
    app = QApplication(sys.argv)
    window = SO101MoveItWindow()
    window.show()

    def request_quit(*_):
        window.close()
        app.quit()

    signal.signal(signal.SIGINT, request_quit)
    signal.signal(signal.SIGTERM, request_quit)

    signal_timer = QTimer()
    signal_timer.start(100)
    signal_timer.timeout.connect(lambda: None)

    sys.exit(app.exec_())


if __name__ == "__main__":
    main()
