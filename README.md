# VHSImageStitch — VHS Video Stitching & Super-Resolution

**Turn old VHS recordings into larger stitched pictures.** Runs locally on Windows 10/11 (64-bit). No Python installation or GPU required.

![VHSImageStitch: moiré edge view on the left, stitched picture on the right](pic.png)

## Download for Windows

**[Download the Windows EXE from the latest release](https://github.com/anttiluode/VHSImageStitch/releases/latest)**

Under **Assets**, choose either:

- **`VHSImageStitch-Windows-x64.exe`** — a single file. Save it and double-click to open the program.
- **`VHSImageStitch-Windows-x64-Portable.zip`** — extract the ZIP, open the `VHSImageStitch` folder, and run `VHSImageStitch.exe`. Keep the `_internal` folder alongside it.

**Do not choose “Source code (zip)”** if you just want to run the program; that download contains Python source, not the Windows application.

## How to use

1. **Open the EXE.** Press **`O`** and choose your VHS video (MP4, AVI or another format supported by OpenCV), or use the webcam.
2. **Press `M`** to show the orange/purple Sigh moiré image. For VHS, this is particularly helpful: tune the frequency graph at bottom left to make **stable edges**—doorframes, walls, furniture and windows—stand out instead of tape grain or noisy textures. Try the curve in the screenshot above or press **`3`** for the *Low-Mid Structural* preset.
3. **Play the video** with **Space**. The program aligns overlapping frames into the stitched atlas on the right.
4. **Press `S` to save** the stitched PNG in the `sweepatlas_output` folder.

**Note:** `M` changes the *view*, not whether moiré matching is active. The frequency graph changes the filter actually used for matching. There is no single best setting for every VHS tape.

### Useful controls

| Key or control | What it does |
|---|---|
| **O** | Open video |
| **M** | Show/hide full moiré view |
| **1–4** | Frequency filter presets |
| **Drag frequency graph** | Emphasize useful edges, suppress noise |
| **Space** | Pause/resume |
| **Drag timeline** | Scrub video |
| **Drag left image** | Crop VHS borders/date stamps (resets atlas) |
| **X** | Clear crop |
| **+ / − or mouse wheel** | Zoom the stitched picture display |
| **G** | Toggle conservative ghosting/parallax guard |
| **L** | Relocalize after tracking loss |
| **R** | Start a fresh stitched atlas |
| **S** | Save PNG |
| **Q / Esc** | Quit |

Stitching works best with **slow camera movements and overlapping frames**. Large sideways moves through a 3D room can cause double edges because nearby and faraway objects move differently. The **2× atlas grid** does not guarantee twice the true detail of the original VHS.

## Where does the EXE come from?

**It is built automatically here on GitHub from the Python source in this repository.** Nothing needs to be downloaded from an unknown third-party site.

- **[Python source: `SweepAtlasSigh.py`](SweepAtlasSigh.py)** — inspect or run the original program.
- **[Windows build script](build-windows.ps1)** — uses PyInstaller to bundle Python, NumPy and OpenCV with the application.
- **[GitHub build workflow](.github/workflows/windows-exe.yml)** — runs on a Windows x64 GitHub Actions computer and checks the packaged program with a synthetic zoom/registration self-test.
- **[Release publishing workflow](.github/workflows/publish-release.yml)** — builds from the release's tagged source and attaches the Windows downloads.

You can inspect all the code and the [public build results](https://github.com/anttiluode/VHSImageStitch/actions) yourself. The EXE is **unsigned**, so Windows may warn that it is an unfamiliar application. The automated self-test checks registration, not every possible VHS file or Windows PC.

### Run from Python instead

```powershell
python -m pip install opencv-python numpy
python SweepAtlasSigh.py --video "your_video.mp4"
```

That's it—**download, open a video, tune the moiré edges, stitch, save**.
