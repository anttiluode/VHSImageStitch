# VHSImageStitch — Sigh Moiré VHS Stitching & Super-Resolution

**Turn moving VHS footage into a wider, accumulated view of the scene.** VHSImageStitch (SweepAtlasSigh) combines a tunable **Sigh frequency-filtered moiré/edge view**, geometric frame registration, and a tiled **2× super-resolution atlas**. It accepts local video files or a webcam, and runs locally with Python, OpenCV, and NumPy.

![SweepAtlasSigh: VHS moiré edge view and accumulated 2× atlas](pic.png)

> **VHS tip: press `M`, and tune the frequency graph until the *structural edges* become clear.** The doorframes, furniture outlines, window edges, and other stable boundaries can be easier to match than washed-out, noisy VHS textures. The screenshot above shows an example of raising selected low/mid frequency bands while keeping many noise-heavy bands low. **There is no single correct EQ curve for every tape.**

**Important:** `M` toggles the **display** of the Sigh moiré representation; it does **not** turn moiré matching on or off. The algorithm computes moiré features for tracking even while the left pane shows ordinary RGB video. Keep the `M` view **on while tuning** because it lets you see what the frequency filter is emphasizing.

## What it does

- **Sigh moiré edge/carrier extraction:** applies a configurable radial FFT filter to grayscale frames, then detects peaks/troughs and feature descriptors from the filtered image.
- **Frame matching:** uses moiré features and phase correlation, with zoom-tolerant RGB/ORB feature matching as an additional option; RANSAC estimates transformations.
- **Mosaic stitching:** places registered input frames into a growing, tiled image atlas.
- **Super-resolution accumulation:** combines differently positioned image samples using drizzle-like weighting and optional iterative back-projection (IBP).
- **Video controls:** play, pause, scrub, step through frames, jump five seconds, and load another video.
- **Input crop:** exclude dates, overlays, border noise and other unwanted areas before tracking.
- **Adjustable viewing and export:** zoom into the atlas, adjust contrast/sharpness, and save the mosaic to PNG.

The output uses observed image data. **2× is the atlas sampling grid, not a guarantee of 2× real recovered optical detail.** True improvement depends on multiple differently sampled frames, accurate registration, and the quality of the VHS source.

## Install (Windows / Python 3.13)

Download or clone this repository:

```powershell
git clone https://github.com/anttiluode/VHSImageStitch.git
cd VHSImageStitch
python3.13 -m pip install numpy opencv-python
```
In Windows installations where `python3.13` is unavailable, use `py -3.13` instead.

### Start with a video

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4"
```

Replace `test3.mp4` with your actual VHS capture or video file. The file may be an MP4, AVI or another format your OpenCV video backend can decode.

### Start with the webcam

```powershell
python3.13 SweepAtlasSigh.py
```

You can also launch the app and press **`O`** to select a video with a file dialog.

### Run the alignment self-test

```powershell
python3.13 SweepAtlasSigh.py --self-test
```

This is a **synthetic zoom/pan registration test**. It is **not** a validation of real VHS super-resolution or 3D reconstruction.

## Recommended VHS workflow: make edges stand out

**For blurry, interlaced, noisy or low-contrast analog recordings, start here.**

1. **Load the tape capture**, then press **`M`**. The left pane becomes the Sigh moiré view, with its detected points shown on top.
2. **Look at the frequency equalizer graph at the bottom left.** The ten draggable points run from lower to higher *spatial frequencies*, not audio frequencies or physical hertz.
3. **Try a low/mid-frequency structural profile.** Raise bands that reveal persistent outlines such as door edges, windows, walls and furniture. Lower bands that mostly reveal tape noise, grain, unstable horizontal lines or compression artifacts. The illustrated curve is a good *visual starting point*, not a universal setting.
4. **Use presets `1`–`4` for quick comparisons.** In particular, try **`3`: Low-Mid Structural**, or **`2`: Clean Sigh BandPass**. Drag individual EQ points for the current recording.
5. **Watch the left-side structure and the right-side result together.** The goal is stable, repeatable edge landmarks—not simply the brightest or most dramatic moiré image.
6. **Crop away VHS borders or timestamps** if they interfere. Drag a rectangle on the left pane; press `X` (or right-click) to remove the crop. Changing the crop resets the accumulated atlas.
7. **Play through a slow, overlapping camera sweep.** Let many frames contribute. If alignment fails, pause, try a different frequency profile, or use `L` to relocalize against saved keyframes.
8. **Press `S` to export** the stitched atlas as a PNG.

### How to tune the frequency graph

The project calls this visual representation **Sigh moiré**. Technically, the code performs a **radial FFT band-pass weighting** followed by inverse FFT and local extrema detection. The colorful preview visualizes filtered spatial structure; it is not a claim that the recording contains a newly discovered physical carrier.

**What you want:** stable contours and distinctive corners that survive changes in frame position.

**What you generally don't want:** filters dominated by VHS grain, scan-line interference, rapidly changing texture, thick featureless blobs, or duplicated edges from ringing.

In many VHS scenes, a few fairly strong low-to-middle spatial-frequency peaks and lower gains toward the extreme bands are a sensible starting point. Use **the image and feature stability** to decide. Stronger filtering is not automatically better.

The pipeline can also fall back to scale-pyramid RGB ORB features when the moiré signal is insufficient. If you want to compare their contribution, use `--no-rgb-features` as an A/B test.

## Keyboard and mouse controls

| Control | Action |
|---|---|
| **M** | Show/hide the full-size moiré view; underlying moiré tracking stays active |
| **1–4** | Select a frequency EQ preset |
| **Drag bottom-left EQ graph** | Change individual frequency-band gains |
| **Drag on left image** | Set an input crop; resets atlas |
| **X / right-click left pane** | Clear crop; resets atlas |
| **Space** | Pause/resume |
| **O** | Open another video |
| **, / .** or **left/right arrow** | Step backward/forward one video frame |
| **J / K** | Jump back/forward about five seconds |
| **Drag timeline** | Seek video; seek previews do not retroactively stitch every skipped frame |
| **+ / -** or **mouse wheel over atlas** | Zoom the *display* of the right-hand mosaic |
| **Z** | Toggle raw-versus-super-resolution comparison loupe |
| **W** | Cycle similarity, euclidean, affine, homography; resets atlas |
| **L** | Attempt relocalization using older keyframes |
| **G** | Toggle conservative 3D/parallax disagreement guard for *future* merges |
| **P** | Toggle motion predictor |
| **U** | Cycle 1×, 2×, 3× atlas grid; resets atlas |
| **B** | Cycle IBP residual gain |
| **C** | Reset display contrast and sharpness |
| **R** | Reset the atlas, preserving current EQ |
| **S** | Save PNG |
| **Q / Esc** | Exit; autosave unless disabled |

**Note:** display zoom (`+`, `-`, mouse wheel) is different from the `--super-res` grid resolution and from camera/optical zoom.

## Useful command-line examples

Default 2× atlas and zoom-aware similarity registration:

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4"
```

Process more source frames per second and allow greater scale changes between matched keyframes:

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4" --process-hz 12 --zoom-limit 1.8
```

Be more conservative when VHS footage contains different depths and moving objects:

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4" --mode similarity --ibp-gain 0.15 --parallax-guard
```

Use 3× output sampling (slower, more memory, and *not automatically sharper*):

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4" --super-res 3.0
```

Set output directory:

```powershell
python3.13 SweepAtlasSigh.py --video "test3.mp4" --out "my_vhs_atlases"
```

Other arguments include `--camera`, `--width`, `--height`, `--crop x,y,w,h` (normalized coordinates), `--moire-width`, `--min-inliers`, `--tile-size`, `--max-tiles`, `--max-export-mp` and `--no-autosave`.

Full options:

```powershell
python3.13 SweepAtlasSigh.py --help
```

## How alignment modes differ

| Mode | Best use | Limitation |
|---|---|---|
| **similarity** (default) | Most ordinary pans, rotations and moderate zoom | No shear or perspective correction |
| **euclidean** | Camera rotation/translation without zoom | Rejects meaningful scale change |
| **affine** | Limited scale, skew and shear | Still cannot handle general perspective or parallax |
| **homography** | Approximately flat surfaces or camera rotation about its optical center | May bend a real 3D room into a misleading plane |

**Why the room can drift:** when the camera moves sideways, nearby furniture moves differently from the far wall. That is **parallax**. A single 2D similarity/affine/homography transform cannot perfectly align all objects at different depths. The `G` guard can reject disagreeing pixels but does not solve the underlying 3D geometry. Avoid fast sideways movement, large parallax, rolling blur and moving foreground objects when making one flat atlas.

## Troubleshooting

**The atlas loses tracking or jumps.** Try a steadier sweep, more frame overlap, a suitable EQ profile, `L` relocalization, or slightly higher `--process-hz`. For actual zoom, keep **similarity** mode and consider `--zoom-limit 1.8`. Huge limits can also admit bad matches.

**The moiré preview looks beautiful but the atlas is wrong.** A sharp filtered visualization is not proof of correct feature correspondence. Tune for *repeatable corners and outlines*, and check the right-hand atlas for duplicated structures.

**Objects have double edges/ghosting.** Try `G` / `--parallax-guard`, lower `--ibp-gain`, and smaller camera movements. Ghosts already blended into the atlas are not removed when the guard is turned on; press `R` for a fresh run if needed.

**VHS bars, timestamps or borders dominate tracking.** Crop them out before the sweep. Avoid including static overlays that move differently from the recorded scene.

**The output looks bigger but not truly sharper.** SR accumulation needs accurate subpixel registration and genuine variation among input frames. VHS noise, motion blur, source upscaling and large viewpoint changes can eliminate the gain. Compare against a conventional resized source, not only against the smaller original display.

**The preview is slow.** Reduce `--super-res`, frame size, `--process-hz`, or IBP gain. Large atlases require substantial RAM.

## Output and project status

Press **S** to export the current atlas into `sweepatlas_output/` by default. A saved image is a **2D composite of observed video frames**, not a reconstructed 3D room or a verified recovery of details never captured by the tape.

The current implementation is experimental, with synthetic registration self-tests and interactive VHS/video use. Real-video reconstruction quality varies with scene geometry, tape quality, camera motion, and EQ settings. In particular, a 3D room is not globally planar and the parallax guard is a conservative merge heuristic rather than depth estimation.

Built as part of the [Antti Luode research repositories](https://github.com/anttiluode), combining Sigh-style frequency exploration with practical local image stitching.

**Explore it, tune the edges, keep the original footage, and judge the result from the saved pixels.**
