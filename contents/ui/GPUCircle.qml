import QtQuick 2.15

Item {
    id: gauge
    property int gpuPercent: 0
    property int memPercent: 0
    property int tempPercent: 0
    property int displayedGpu: 0
    property int displayedMem: 0
    property int displayedTemp: 0
    property real circleSize: 38

    width: circleSize
    height: circleSize

    // --- Animations for smooth updates ---
    NumberAnimation on displayedGpu {
        duration: 700
        easing.type: Easing.InOutQuad
    }
    NumberAnimation on displayedMem {
        duration: 700
        easing.type: Easing.InOutQuad
    }
    NumberAnimation on displayedTemp {
        duration: 700
        easing.type: Easing.InOutQuad
    }

    // --- Sync values to animate ---
    onGpuPercentChanged: displayedGpu = gpuPercent
    onMemPercentChanged: displayedMem = memPercent
    onTempPercentChanged: displayedTemp = tempPercent

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.antialias = true;
            ctx.translate(width / 2, height / 2);

            const outerR = width * 0.45;   // GPU
            const midR   = width * 0.35;   // VRAM
            const innerR = width * 0.25;   // Temperature

            ctx.lineCap = "round";
            ctx.lineWidth = 3;

            // --- Background rings ---
            ctx.strokeStyle = "#333";
            for (let r of [outerR, midR, innerR]) {
                ctx.beginPath();
                ctx.arc(0, 0, r, 0, 2 * Math.PI);
                ctx.stroke();
            }

            // --- GPU (green outer ring) ---
            ctx.strokeStyle = "#00c853";
            ctx.beginPath();
            ctx.arc(0, 0, outerR, -Math.PI / 2,
                (2 * Math.PI * displayedGpu / 100) - Math.PI / 2);
            ctx.stroke();

            // --- VRAM (blue middle ring) ---
            ctx.strokeStyle = "#2962ff";
            ctx.beginPath();
            ctx.arc(0, 0, midR, -Math.PI / 2,
                (2 * Math.PI * displayedMem / 100) - Math.PI / 2);
            ctx.stroke();

            // --- Temperature (red inner ring) ---
            ctx.strokeStyle = "#ff1744";
            ctx.beginPath();
            ctx.arc(0, 0, innerR, -Math.PI / 2,
                (2 * Math.PI * displayedTemp / 100) - Math.PI / 2);
            ctx.stroke();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // Redraw on animation updates
    onDisplayedGpuChanged: canvas.requestPaint()
    onDisplayedMemChanged: canvas.requestPaint()
    onDisplayedTempChanged: canvas.requestPaint()
}
