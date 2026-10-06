import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Window

import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import org.kde.plasma.wallpapers.potd
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root

    contextualActions: [
        PlasmaCore.Action {
            text: "Refresh image"
            icon.name: "view-refresh"
            // A new value is a new cache entry, so the provider fetches again
            onTriggered: root.configuration.Refresh = Date.now().toString()
        },
        PlasmaCore.Action {
            text: "Open Wallpaper Image"
            icon.name: "document-open"
            onTriggered: Qt.openUrlExternally(backend.localUrl);
        }
    ]

    QQC2.StackView {
        id: imageView
        anchors.fill: parent

        readonly property int fillMode: root.configuration.FillMode
        readonly property size sourceSize: Qt.size(imageView.width * Screen.devicePixelRatio, imageView.height * Screen.devicePixelRatio)
        property Item pendingImage
        property bool doesSkipAnimation: true

        onFillModeChanged: Qt.callLater(imageView.loadImage)
        onSourceSizeChanged: Qt.callLater(imageView.loadImage)

        function loadImage() {
            if (backend.localUrl.length === 0) {
                return;
            }
            if (imageView.pendingImage) {
                imageView.pendingImage.statusChanged.disconnect(replaceWhenLoaded);
                imageView.pendingImage.destroy();
                imageView.pendingImage = null;
            }

            imageView.doesSkipAnimation = imageView.empty || sourceSize !== imageView.currentItem.sourceSize;
            imageView.pendingImage = imageComponent.createObject(imageView, {
                "source": backend.localUrl,
                "fillMode": imageView.fillMode,
                "opacity": imageView.doesSkipAnimation ? 1 : 0,
                "sourceSize": imageView.sourceSize,
                "width": imageView.width,
                "height": imageView.height,
            });
            imageView.pendingImage.statusChanged.connect(imageView.replaceWhenLoaded);
            imageView.replaceWhenLoaded();
        }

        function replaceWhenLoaded() {
            if (imageView.pendingImage.status === Image.Loading) {
                return;
            }
            imageView.pendingImage.statusChanged.disconnect(imageView.replaceWhenLoaded);
            imageView.replace(imageView.pendingImage, {}, imageView.doesSkipAnimation ? QQC2.StackView.Immediate : QQC2.StackView.Transition);
            imageView.pendingImage = null;
        }

        PotdBackend {
            id: backend
            identifier: "windowsspotlight"
            // Provider arguments: market country code, locale, cache limit, refresh token
            arguments: root.configuration.Refresh.length > 0
                ? [root.configuration.Country, root.configuration.Locale, root.configuration.CacheLimit, root.configuration.Refresh]
                : [root.configuration.Country, root.configuration.Locale, root.configuration.CacheLimit]

            onImageChanged: Qt.callLater(imageView.loadImage)
            onLocalUrlChanged: Qt.callLater(imageView.loadImage)
        }

        Component {
            id: imageComponent

            Image {
                asynchronous: true
                cache: false
                autoTransform: true
                smooth: true

                QQC2.StackView.onActivated: root.accentColorChanged()
                QQC2.StackView.onDeactivated: destroy()
                QQC2.StackView.onRemoved: destroy()
            }
        }

        Rectangle {
            id: backgroundColor
            anchors.fill: parent
            color: root.configuration.Color
            Behavior on color {
                ColorAnimation { duration: Kirigami.Units.longDuration }
            }
        }

        replaceEnter: Transition {
            OpacityAnimator {
                id: replaceEnterOpacityAnimator
                to: 1
                // As the wallpaper is updated once a day, the transition should be longer.
                duration: Math.round(Kirigami.Units.veryLongDuration * 5)
            }
        }
        // Keep the old image around till the new one is fully faded in
        replaceExit: Transition {
            PauseAnimation {
                duration: replaceEnterOpacityAnimator.duration + 500
            }
        }
    }
}
