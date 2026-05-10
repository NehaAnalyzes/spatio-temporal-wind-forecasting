# Spatio-Temporal Wind Forecasting

ST-LSTM based spatio-temporal deep learning framework for short-term wind speed forecasting using graph-based spatial aggregation and temporal sequence learning.

## Overview

This project proposes a Spatio-Temporal Long Short-Term Memory (ST-LSTM) forecasting framework for short-term wind speed prediction using geographically distributed wind monitoring stations.

The framework combines:

- Spatial dependency modeling using graph-based aggregation
- Temporal sequence learning using LSTM networks
- Multi-step wind speed forecasting
- Spatio-temporal feature extraction from multivariate wind data

The model was implemented using PyTorch and evaluated on multi-site wind monitoring data collected from 234 geographically distributed monitoring stations. :contentReference[oaicite:0]{index=0}

---

## Features

- ST-LSTM based forecasting architecture
- Graph-based spatial aggregation
- Multi-step forecasting capability
- PyTorch implementation with GPU training
- Spatial graph construction using Haversine distance
- Sliding window sequence generation
- Mixed precision training
- Cosine annealing learning rate scheduling
- Early stopping and gradient clipping

---

## Methodology

The workflow of the proposed framework includes:

1. Data Collection and Cleaning
2. Exploratory Data Analysis
3. Feature Engineering and Sequence Generation
4. Spatial Graph Construction
5. ST-LSTM Model Training
6. Forecast Evaluation and Testing

The proposed ST-LSTM framework integrates:

- Feature Projection Layers
- Bottleneck Compression
- Spatial Aggregation
- Residual Fusion
- LSTM Temporal Learning
- Layer Normalization and Dropout
- Fully Connected Prediction Layers

---

## Dataset

The dataset consists of:

- 234 wind monitoring stations
- 10-minute interval observations
- Geographically distributed monitoring locations
- Multivariate wind monitoring data

Dataset split:

- Training Stations: 155
- Validation Stations: 40
- Testing Stations: 39

---

## Forecasting Tasks

The framework supports:

### Single-Step Forecasting
Prediction of the next wind speed value.

### Multi-Step Forecasting
Prediction of the next 6 wind speed values (1 hour ahead forecasting).

---

## Performance

### Single-Step Forecasting

| Metric | Value |
|---|---|
| RMSE | 1.8066 |
| MAE | 1.3092 |
| R² | 0.7652 |

### Multi-Step Forecasting

| Metric | Value |
|---|---|
| RMSE | 2.0318 |
| R² | 0.7002 |

The proposed ST-LSTM framework demonstrated stable forecasting performance across geographically unseen monitoring stations. :contentReference[oaicite:1]{index=1}

---

## Technologies Used

- Python
- PyTorch
- NumPy
- Pandas
- Scikit-learn
- Matplotlib

---

## Results

The model successfully captured:

- Temporal wind speed dynamics
- Spatial relationships between monitoring stations
- Nonlinear forecasting patterns
- Multi-site forecasting behavior

Training and validation losses showed stable convergence during training. :contentReference[oaicite:2]{index=2}

---

## Future Improvements

Potential future enhancements include:

- Transformer-based forecasting models
- Attention mechanisms
- Probabilistic forecasting
- Real-time forecasting systems
- Integration of additional meteorological parameters

