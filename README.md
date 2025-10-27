# gpuusage_kde

## (gpuusage_kde)

* Description: KDE Widget that monitors NVIDIA GPU usage
* Copyright: AXISFX LTD
* Author: Ewan Davidson
* Email: ewan@axisfx.design
* Release Date: 27.10.2025
* Current Version: 1.0

## Features

* Utilization shown in red
* VRAM Usage shown in blue
* Temperature shown in red
* Supports multiple GPUs

![Alt text](./preview.jpg)

## Negative Features

* Coded with AI (I'm not learning qml or javascript)
* Tested only on KDE version 5.24.7

## Dependencies

* nvidia-smi
* KDE version 5.24.7

## Installation

### Using kpackagetool5 (recommended)

```bash
kpackagetool5 --type Plasma/Applet --install ./gpuusage_kde
```

If the plasmoid is already present, replace `--install` with `--upgrade`. Afterwards, right-click the panel or desktop, choose *Add Widgets…*, search for **GPU Usage**, and add it where you need it.

### Manual install to ~/.local/share

```bash
mkdir -p ~/.local/share/plasma/plasmoids/
cp -r ./gpuusage_kde ~/.local/share/plasma/plasmoids/gpuusage_kde
kquitapp5 plasmashell
plasmashell --replace &
```

Once Plasma has restarted, add the widget via *Add Widgets…* as above.


## Changes

### 1.0  |  27.10.2025

* Initial release