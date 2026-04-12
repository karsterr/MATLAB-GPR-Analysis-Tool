# 📡 GPR 3D Modeling Project: RF & DSP-Based Underground Analysis Tool

> An academic project dedicated to processing and analyzing Ground Penetrating Radar (GPR) data to map underground anomalies in 3D using pure Digital Signal Processing (DSP) techniques.

## 📖 Abstract & Introduction

Underground mapping is critical for detecting structures such as pipes, cables, and caves, especially in urban infrastructure projects and archaeological studies. GPR devices provide high-resolution profiles of the subsurface using electromagnetic waves. 

This project aims to filter out noise from complex GPR data to make targets identifiable through artificial classifications. **Ready-made image processing libraries were intentionally avoided.** Instead, the project relies exclusively on pure signal processing (DSP) approaches. This ensures that the soil structure and the reflection characteristics of underground targets are examined in depth and strictly in accordance with electromagnetic principles.

---

## ⚙️ Methodology: DSP Pipeline

To extract maximum information from the GPR data, the following mathematical steps are applied sequentially on a signal basis:

1. **Data Preprocessing (Zero-Padding):** GPR cross-sections with varying scan lengths and data matrices are resized using the zero-padding method to ensure they share a common volume (grid) of the same size.
2. **De-wow (Centering):** Removes direct current (DC) offsets, very low-frequency noise, or drift effects originating from the device or antenna connections.
3. **Background Removal:** Antenna-induced noise (e.g., direct waves) that is common across all traces and appears as horizontal lines is cleaned using the mean subtraction technique along the horizontal plane.
4. **Gain Application:** Because electromagnetic waves attenuate as they travel deeper, depth-dependent (time-dependent) geometric gain formulas (e.g., exponential gain) are applied to amplify weak reflections from deeper points.
5. **Envelope Detection:** To analyze the signal's energy (thickness) rather than its rapid oscillations, the envelope of the signal is obtained using the Hilbert Transform or equivalent mathematical methods.

---

## 🏗️ Architecture & Operation

The system is built around modular `.m` scripts to ensure clean and maintainable code:

* **`load_gpr_data.m`**: Automatically reads multi-section scan data added to the `dataset/` directory.
* **`main.m`**: The core orchestrator. It hierarchically calls helper functions, runs the GPR data through the DSP filters, and prepares it for 3D visualization.

---

## 🔍 Thresholding & Classification Logic

A classification based on signal amplitude is performed to distinguish various underground structures. In the final stage, the entire dataset is plotted in 3D space using the `scatter3` function, color-coded according to material type using a custom Colormap.

| Target Type | Signal Characteristics |
| :--- | :--- |
| **Main / Thick Pipe** | Targets exhibiting the highest signal amplitudes. |
| **Thin Pipe** | Targets with medium amplitude where energy is concentrated in a more restricted area. |
| **Cable** | Lower regional and thin scatterings of the signal. |
| **Cave / Cavity** | Sharper structures where the signal continues, leaving phase shifts (bright echoes) behind. Separated by specific threshold limits within the code. |

---

## 🚀 Installation & Usage

Follow these steps to run the project on your local machine:

### Prerequisites
* **MATLAB** (Ensure you have a recent version installed)

### Setup Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   ```
2. **Download the dataset:**
   Fetch the required GPR dataset from Mendeley Data:
   [Download Dataset Here](https://data.mendeley.com/datasets/by3yh79hx4/1)
3. **Place the data:**
   Extract and move the downloaded dataset (large files) into the `dataset/` folder within your cloned project directory.
4. **Configure MATLAB:**
   Open MATLAB and set the project folder as your active working directory (*Current Folder*).
5. **Run the pipeline:**
   Execute the `main.m` script. 
   
   *You can monitor each processing step in the MATLAB console output. Upon completion, a 3D scatter plot of the subsurface will be generated.*
