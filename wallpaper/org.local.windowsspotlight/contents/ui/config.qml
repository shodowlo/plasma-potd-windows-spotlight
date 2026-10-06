import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kquickcontrols as KQC2
import org.kde.kirigami as Kirigami

import org.kde.plasma.wallpapers.potd

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout

    property string cfg_Country
    property string cfg_Locale
    property string cfg_Refresh
    property int cfg_CacheLimit
    property int cfg_FillMode
    property alias cfg_Color: colorButton.color

    onCfg_FillModeChanged: resizeComboBox.setMethod()

    // Spotlight markets known to return images (country code, locale)
    readonly property var markets: [
        { label: "France", country: "FR", locale: "fr-FR" },
        { label: "Belgium", country: "BE", locale: "fr-BE" },
        { label: "Canada (English)", country: "CA", locale: "en-CA" },
        { label: "Canada (French)", country: "CA", locale: "fr-CA" },
        { label: "United States", country: "US", locale: "en-US" },
        { label: "United Kingdom", country: "GB", locale: "en-GB" },
        { label: "Germany", country: "DE", locale: "de-DE" },
        { label: "Spain", country: "ES", locale: "es-ES" },
        { label: "Italy", country: "IT", locale: "it-IT" },
        { label: "Japan", country: "JP", locale: "ja-JP" }
    ]

    // Same arguments as the wallpaper, so this shows the image that is displayed
    PotdBackend {
        id: backend
        identifier: "windowsspotlight"
        arguments: root.cfg_Refresh.length > 0
            ? [root.cfg_Country, root.cfg_Locale, root.cfg_CacheLimit, root.cfg_Refresh]
            : [root.cfg_Country, root.cfg_Locale, root.cfg_CacheLimit]
    }

    QQC2.ComboBox {
        id: regionComboBox
        Kirigami.FormData.label: "Region:"
        model: root.markets
        textRole: "label"
        onActivated: {
            root.cfg_Country = model[currentIndex]["country"];
            root.cfg_Locale = model[currentIndex]["locale"];
        }
        Component.onCompleted: setMarket()

        function setMarket() {
            for (var i = 0; i < model.length; i++) {
                if (model[i]["country"] === root.cfg_Country && model[i]["locale"] === root.cfg_Locale) {
                    regionComboBox.currentIndex = i;
                    break;
                }
            }
        }
    }

    QQC2.SpinBox {
        id: cacheLimitSpinBox
        Kirigami.FormData.label: "Images kept in cache:"
        from: 1
        to: 100
        value: root.cfg_CacheLimit
        onValueModified: root.cfg_CacheLimit = value
    }

    QQC2.Button {
        Kirigami.FormData.label: "Current image:"
        text: "Refresh image"
        icon.name: "view-refresh"
        // Takes effect when Apply is clicked
        onClicked: root.cfg_Refresh = Date.now().toString()
    }

    QQC2.Button {
        Kirigami.FormData.label: "Cache:"
        text: "Open cache folder"
        icon.name: "folder-open"
        enabled: backend.localUrl.length > 0
        // The cached image lives in the cache folder, so open the folder that contains it
        onClicked: Qt.openUrlExternally(backend.localUrl.substring(0, backend.localUrl.lastIndexOf("/")))
    }

    Kirigami.SelectableLabel {
        Kirigami.FormData.label: "Title:"
        Layout.fillWidth: true
        visible: backend.title.length > 0
        font.bold: true
        text: backend.title
    }

    Kirigami.SelectableLabel {
        Kirigami.FormData.label: "Author:"
        Layout.fillWidth: true
        visible: backend.author.length > 0
        text: backend.author
    }

    // Fixed-size container, so the form layout reserves the right space
    Item {
        Kirigami.FormData.label: "Preview:"
        implicitWidth: Kirigami.Units.gridUnit * 16
        implicitHeight: Kirigami.Units.gridUnit * 9
        visible: backend.localUrl.length > 0

        Image {
            anchors.fill: parent
            source: backend.localUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            autoTransform: true
            smooth: true
        }
    }

    QQC2.ComboBox {
        id: resizeComboBox
        Kirigami.FormData.label: "Positioning:"
        model: [
            { 'label': "Scaled and cropped", 'fillMode': Image.PreserveAspectCrop },
            { 'label': "Scaled", 'fillMode': Image.Stretch },
            { 'label': "Scaled, keep proportions", 'fillMode': Image.PreserveAspectFit },
            { 'label': "Centered", 'fillMode': Image.Pad },
            { 'label': "Tiled", 'fillMode': Image.Tile }
        ]
        textRole: "label"
        onActivated: root.cfg_FillMode = model[currentIndex]["fillMode"]
        Component.onCompleted: setMethod()

        function setMethod() {
            for (var i = 0; i < model.length; i++) {
                if (model[i]["fillMode"] === root.cfg_FillMode) {
                    resizeComboBox.currentIndex = i;
                    break;
                }
            }
        }
    }

    KQC2.ColorButton {
        id: colorButton
        Kirigami.FormData.label: "Background color:"
        dialogTitle: "Choose background color"
    }
}
