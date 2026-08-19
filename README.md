# runpod-vipe-gsplat

This repository combines [ViPE](https://github.com/nv-tlabs/vipe) and
[gsplat](https://github.com/nerfstudio-project/gsplat) into a single container
image, where ViPE can be used to process videos and images into pose estimates
and point clouds, which can be fed into gsplat to train 3D Gaussian splatting
models.

## Basic usage

1. Use ViPE to generate pose estimates and a sparse point cloud, as described in
   [this tutorial](https://github.com/sruggier/vipe/blob/tutorial/README.md),
   with one minor adjustment: when configuring a pod, use
   [this template](https://console.runpod.io/hub/template/qnkno00wff) instead.
   It uses the `docker.io/sruggier/runpod-vipe-gsplat:main`, which includes
   gsplat in the system-wide Python environment.

2. After exporting data to `/workspace/output/COLMAP`, start training a Gaussian
   splatting model like so:

   ```bash
   mkdir -p /workspace/output/gsplat
   INPUT_DIR=/workspace/output/COLMAP/<directory>_sparse/; \
   OUTPUT_DIR=/workspace/output/gsplat; \
   CUDA_VISIBLE_DEVICES=0 python /gsplat/examples/simple_trainer.py \
   	mcmc \
   	--disable-viewer \
   	--data-dir "$INPUT_DIR" \
   	--data-factor 1 \
   	--result-dir "$OUTPUT_DIR"/"$(basename "$INPUT_DIR")-$(date --iso-8601=minutes)" \
   	--strategy.cap_max 3_000_000 \
   	--antialiased \
   	--steps-scaler 2 \
   	--save-ply \
   	--ply-steps 15000 30000 \
   	--save-steps 15000 30000 \
   	# Disable test split/eval, sacrificing rigor for possibly better visual
   	# results
   	--test-every 1000 \
   	--eval-steps 1000000
   ```
