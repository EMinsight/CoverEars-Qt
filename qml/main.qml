import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import Downloader 1.0
Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("迅雷不及掩耳")
    Downloader {
        id: downloader
    }
    Column {
        width: parent.width
        Row {
            width: parent.width
            height: 40
            spacing: 10
            Label {
                id: label
                text: qsTr("网址")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: 80
                height: parent.height
            }
            TextField {
                id: urlInput
                height: parent.height
                width: parent.width - label.width - 10
                verticalAlignment: Text.AlignVCenter
                selectByMouse: true
                focus: true
                text: "http://download.qt.io/linguist_releases/qtlinguistinstaller-5.12.2.exe"
            }
        }
        Row {
            width: parent.width
            height: 40
            spacing: 10
            Label {
                text: qsTr("多进程数:")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                width: 80
                height: parent.height
            }
            ComboBox {
                id: comboBox
                model:[1, 2, 3, 4, 5, 6]
                width: 80
                height: parent.height
            }
            Button {
                text: qsTr("下载")
                enabled: !downloader.isDownloading
                onClicked: {
                    downloader.download(urlInput.text, parseInt(comboBox.currentText))
                }
            }
            Button {
                text: qsTr("查看文件夹")
                onClicked: {
                    Qt.openUrlExternally(downloader.folder)
                }
            }
        }
    }

}
