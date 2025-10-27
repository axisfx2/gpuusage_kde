// This script runs in the plasmoid's JavaScript context

// kpackagetool5 --type Plasma/Applet --remove gpuusage
// kpackagetool5 --type Plasma/Applet --install /mnt/studio/Rez/kde_widgets/gpuusage/
// kquitapp5 plasmashell
// QT_LOGGING_RULES="qt.qml.debug=true;qt.qml.warning=true" plasmashell --replace

function readGpuStats() {
    var proc = new QProcess();
    proc.start("nvidia-smi", [
        "--query-gpu=utilization.gpu,memory.used,memory.total",
        "--format=csv,noheader,nounits"
    ]);
    proc.waitForFinished();
    var output = proc.readAllStandardOutput().toString().trim().split("\n");
    var gpus = [];
    for (var i = 0; i < output.length; i++) {
        var parts = output[i].split(",");
        if (parts.length < 3) continue;
        var gpu = parseInt(parts[0]);
        var used = parseInt(parts[1]);
        var total = parseInt(parts[2]);
        var mem = Math.round((used / total) * 100);
        gpus.push({gpu: gpu, mem: mem});
    }
    return gpus;
}
