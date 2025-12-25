# GPR Data Verification Suite

## Overview
This repository contains a set of MATLAB scripts designed for the advanced visualization, processing, and verification of Ground Penetrating Radar (GPR) data. The suite enables the comparison of simulated GPR reflection data against a ground truth porosity model, utilizing HDF5 data formats.

The primary objective is to validate subsurface radar detections by correlating signal amplitudes with the physical properties (porosity) of the modeled environment.

## Features

### 1. HDF5 Data Integration
- Efficient handling of high-dimensional `.h5` datasets for both GPR traces and volumetric porosity models.
- Extraction of metadata (center frequency, model discretization, geometry vectors).

### 2. Multi-Dimensional Visualization
- **B-Scans:** Inline and crossline profile slicing.
- **Time-Slices:** Depth-dependent signal analysis.
- **C-Scans:** 2D reduction of 3D data using Maximum Amplitude Projection to map subsurface features.

### 3. Verification & Comparison
- Side-by-side analysis of the GPR signal strength map versus the reference porosity model (Ground Truth).
- Validates the accuracy of the radar simulation against the physical model.

### 4. Optimized 3D Rendering
- Includes a "Smart Downsampling" algorithm to visualize dense 3D GPR point clouds.
- Filters low-energy noise (threshold-based) and limits point count to ensure smooth rendering on standard hardware without data loss in critical regions.

## File Structure

| File Name | Description |
| :--- | :--- |
| `import_gpr_data.m` | Loads raw GPR data and visualizes B-Scans (profile slices) and Time-Slices. |
| `import_porosity_model.m` | Loads and visualizes the reference volumetric porosity model (x-z and x-y slices). |
| `process_gpr_data_2d.m` | Performs the core verification logic. Generates C-Scan maps and compares GPR signals with the porosity model. |
| `process_gpr_data_3d.m` | Optimized 3D visualization script using downsampling and energy thresholding. |
| `GPR_Data.h5` | Input Data: Simulated GPR reflection data. |
| `Porosity_Model.h5` | Input Data: Ground truth volumetric porosity model. |

## Algorithm Details

### C-Scan Mapping (2D Projection)
The 3D GPR data is collapsed into a 2D map to highlight strong reflectors:
$$M(x,y) = \max_{t} |S(x,y,t)|$$
Where $S$ is the signal amplitude. This is compared against the cumulative porosity model.

### 3D Optimization Strategy
To handle large datasets efficiently in `process_gpr_data_3d.m`, the following logic is applied:
1. **Thresholding:** Only data points exceeding 20% of the maximum signal energy are retained.
2. **Downsampling:** If the remaining point count exceeds the target limit (e.g., 30,000 points), the dataset is strided to maintain performance while preserving spatial distribution.

## Requirements
- MATLAB R2019b or later.
- Signal Processing Toolbox.
- Image Processing Toolbox.

## Usage
1. Ensure `GPR_Data.h5` and `Porosity_Model.h5` are in the root directory.
2. Run `process_gpr_data_2d.m` to see the verification results (Signal vs. Model).
3. Run `process_gpr_data_3d.m` for the volumetric 3D analysis.
