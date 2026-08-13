FROM sruggier/runpod-vipe:test

# Below lines adapted from
# https://github.com/astral-sh/uv-docker-example/blob/main/Dockerfile

ARG UV_NO_DEV=1
ARG UV_COMPILE_BYTECODE=1
ARG UV_LINK_MODE=copy
ARG UV_NO_EDITABLE=1

RUN <<-EOR
	cat >> /etc/uv/uv.toml <<-EOF
		[extra-build-variables.gsplat]
		TORCH_CUDA_ARCH_LIST= "Ampere;Ada;10.0;12.0"
	EOF
EOR

COPY --from=gsplat . /gsplat
RUN --mount=type=cache,target=/root/.cache/uv \
	uv pip install --system --break-system-packages \
		--no-build-isolation-package gsplat 'gsplat[examples,lidar]@file:///gsplat'
