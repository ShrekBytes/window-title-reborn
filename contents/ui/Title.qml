import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import "../tools/Tools.js" as Tools

GridLayout {
    columns: isVertical?1:7
    anchors.fill: parent
    rowSpacing: 0
    columnSpacing: 0
    Layout.maximumWidth: parent.width
    Layout.maximumHeight: parent.height

    // Calculated label length for fixed/max/minMax modes.
    // For minimum-only (kind 3), the label grows freely, so we use implicitWidth.
    property real labelLen : {
        let neededInViewLen = cfg.firstSpace + cfg.midSpace + cfg.lastSpace + cfg.lastSpace
        neededInViewLen += isVertical ? iconItem.height : iconItem.width
        return cfg.fixedLength - neededInViewLen
    }

    Item {
        Layout.fillWidth: (cfg.horizontalAlignment === 1 || cfg.horizontalAlignment === 2) && !isVertical
        Layout.fillHeight: (cfg.horizontalAlignment === 1 || cfg.horizontalAlignment === 2) && isVertical
    }
    CItem {length: cfg.firstSpace}
    Item {
        id: iconItem
        Layout.minimumWidth   : isVertical  ? parent.width : height
        Layout.minimumHeight  : isVertical  ? width : parent.height
        Layout.maximumWidth   : Layout.minimumWidth
        Layout.maximumHeight  : Layout.minimumHeight
        visible               : cfg.visible
        property int thickness: isVertical ? parent.width : parent.height
        Kirigami.Icon {
            anchors {
                fill         :  parent
                topMargin    : !isVertical ? thickMargin : 0
                bottomMargin : !isVertical ? thickMargin : 0
                leftMargin   :  isVertical ? thickMargin : 0
                rightMargin  :  isVertical ? thickMargin : 0
            }
            source: root.icon
            readonly property int thickMargin: cfg.fillThickness ? 0 : (parent.thickness - iconSize) / 2
            readonly property int iconSize   : cfg.fillThickness ? parent.thickness : Math.min(parent.thickness, cfg.customSize)
        }
    }
    CItem {length: cfg.midSpace}
    CItem{
        // lengthKind:
        //   0 = contents (free)      → label width = implicitWidth
        //   1 = fixed                → label width = labelLen (from fixedLength)
        //   2 = maximum              → label width = min(implicitWidth, labelLen)
        //   3 = minimum              → label grows freely; min enforced by root Layout
        //   4 = min + max            → label width = min(implicitWidth, labelLen)
        length : {
            if      (cfg.lengthKind === 0) return label.implicitWidth
            else if (cfg.lengthKind === 1) return labelLen
            else if (cfg.lengthKind === 2) return Math.min(label.implicitWidth, labelLen)
            else if (cfg.lengthKind === 3) return label.implicitWidth
            else                           return Math.min(label.implicitWidth, labelLen)
        }
        clip: true
        PlasmaComponents.Label {
            id                      : label
            horizontalAlignment     : {
                if (isVertical) return Text.AlignHCenter;
                if (cfg.horizontalAlignment === 0) return Text.AlignLeft;
                if (cfg.horizontalAlignment === 2) return Text.AlignRight;
                return Text.AlignHCenter;
            }
            verticalAlignment       : Text.AlignVCenter
            text                    : root.text
            color                   : Kirigami.Theme.textColor
            elide                   : Tools.getElide(cfg.elidePos)
            width : {
                if      (cfg.lengthKind === 0) return label.implicitWidth
                else if (cfg.lengthKind === 1) return labelLen
                else if (cfg.lengthKind === 2) return Math.min(label.implicitWidth, labelLen)
                else if (cfg.lengthKind === 3) return label.implicitWidth
                else                           return Math.min(label.implicitWidth, labelLen)
            }
            rotation                : isVertical?plasmoid.location===PlasmaCore.Types.LeftEdge?-90:90:0
            anchors.centerIn        : parent
            font {
                capitalization      : cfg.isCaps ? Font.Capitalize : Font.MixedCase
                bold                : cfg.isBold
                italic              : cfg.isItalic
                pixelSize           : cfg.fontSize
            }
        }
    }
    CItem {length:cfg.lastSpace}
    Item {
        Layout.fillWidth: (cfg.horizontalAlignment === 0 || cfg.horizontalAlignment === 1) && !isVertical
        Layout.fillHeight: (cfg.horizontalAlignment === 0 || cfg.horizontalAlignment === 1) && isVertical
    }
}
