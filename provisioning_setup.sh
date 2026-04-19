#!/bin/bash
set -e
source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"

echo "=== MV-Private ComfyUI Setup ==="

# ============================================
# APT & PIP PACKAGES
# ============================================

APT_PACKAGES=(
    "exiftool"
)

PIP_PACKAGES=(
    "lpips"
)

# ============================================
# CUSTOM NODES
# ============================================

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/djbielejeski/a-person-mask-generator"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus"
    "https://github.com/ClownsharkBatwing/RES4LYF"
    "https://github.com/BadCafeCode/masquerade-nodes-comfyui"
    "https://github.com/Zar4X/ComfyUI-Batch-Process"
    "https://github.com/1038lab/ComfyUI-RMBG"
    "https://github.com/storyicon/comfyui_segment_anything"
    "https://github.com/okdalto/ComfyUI-Color-Matcher"
    "https://github.com/aining2022/ComfyUI_Swwan"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler"
    "https://github.com/LAOGOU-666/Comfyui_LG_Tools"
    "https://github.com/Steudio/ComfyUI_Steudio"
    "https://github.com/M1kep/ComfyLiterals"
    "https://github.com/JPS-GER/ComfyUI_JPS-Nodes"
)

# ============================================
# MODELS
# ============================================

DIFFUSION_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors"
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors"
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors"
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors"
)

CHECKPOINTS=(
    "https://huggingface.co/Kutches/XL/resolve/main/lustifySDXLNSFW_ggwpV7.safetensors"
)

TEXT_ENCODERS=(
    "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
)

VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors"
    "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/ae.safetensors"
    "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/Kim2091/UltraSharpV2/resolve/0d73a3fcc798ad4bc612db25bd30c18680265809/4x-UltraSharpV2.pth"
    "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth"
)

LORAS=(
    "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora_fp16.safetensors"
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_low.safetensors"
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_high.safetensors"
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors"
    "https://huggingface.co/Osrivers/Instagirlv2.5-LOW.safetensors/resolve/main/Instagirlv2.5-LOW.safetensors"
    "https://huggingface.co/TheRaf7/ultra-real-wan2.2/resolve/main/Lenovo(1).safetensors"
    "https://huggingface.co/allyourtech/instagirl/resolve/main/Instagirlv2.5-HIGH.safetensors"
    "https://huggingface.co/BAZILEVS-BASED/kontext_big_breasts_and_butts/resolve/main/kontext_big_breasts_and_butts.safetensors"
)

LORAS_CIVITAI=(
    "https://civitai.com/api/download/models/550216?type=Model&format=SafeTensor|lady_hand.safetensors"
    "https://civitai.com/api/download/models/238277?type=Model&format=SafeTensor|real_feet.safetensors"
)

CONTROLNET_MODELS=(
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors"
)

### ─────────────────────────────────────────────
### DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
### ─────────────────────────────────────────────

function provisioning_start() {
    echo ""
    echo "##############################################"
    echo "#   MV-Private Setup                         #"
    echo "##############################################"
    echo ""

    provisioning_get_apt_packages
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_get_pip_packages

    provisioning_get_files \
        "${COMFYUI_DIR}/models/diffusion_models" \
        "${DIFFUSION_MODELS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints/SDXL" \
        "${CHECKPOINTS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${TEXT_ENCODERS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/upscale_models" \
        "${UPSCALE_MODELS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORAS[@]}"

    provisioning_get_civitai_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORAS_CIVITAI[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet/SDXL/controlnet-union-sdxl-1.0" \
        "${CONTROLNET_MODELS[@]}"

    provisioning_install_instaraw_deps

    echo ""
    echo "✅ Setup complete → Starting ComfyUI..."
    echo ""
}

function provisioning_install_base_reqs() {
    cd "${COMFYUI_DIR}"
    if [[ -f requirements.txt ]]; then
        echo "Installing ComfyUI base requirements..."
        pip install --no-cache-dir -r requirements.txt
    fi
}

function provisioning_get_apt_packages() {
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        echo "Installing apt packages..."
        apt-get update && apt-get install -y "${APT_PACKAGES[@]}"
    fi
}

function provisioning_get_pip_packages() {
    if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
        echo "Installing extra pip packages..."
        pip install --no-cache-dir "${PIP_PACKAGES[@]}"
    fi
}

function provisioning_get_nodes() {
    mkdir -p "${COMFYUI_DIR}/custom_nodes"
    cd "${COMFYUI_DIR}/custom_nodes"

    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="./${dir}"

        if [[ -d "$path" ]]; then
            echo "Updating node: $dir"
            (cd "$path" && git pull --ff-only 2>/dev/null || { git fetch && git reset --hard origin/main; })
        else
            echo "Cloning node: $dir"
            git clone "$repo" "$path" --recursive || echo "[!] Clone failed: $repo"
        fi

        if [[ -f "${path}/requirements.txt" ]]; then
            echo "Installing deps for $dir..."
            pip install --no-cache-dir -r "${path}/requirements.txt" || echo "[!] pip failed for $dir"
        fi

        if [[ -f "${path}/install.py" ]]; then
            echo "Running install.py for $dir..."
            cd "$path" && python install.py && cd ..
        fi
    done
}

function provisioning_get_files() {
    if [[ $# -lt 2 ]]; then return; fi
    local dir="$1"
    shift
    local files=("$@")

    mkdir -p "$dir"
    echo "Downloading ${#files[@]} file(s) → $dir..."

    for url in "${files[@]}"; do
        local auth_header=""
        if [[ -n "$HF_TOKEN" && "$url" =~ huggingface\.co ]]; then
            auth_header="--header=Authorization: Bearer $HF_TOKEN"
        fi
        echo "→ $url"
        wget $auth_header -nc --content-disposition --show-progress -e dotbytes=4M -P "$dir" "$url" || echo "[!] Download failed: $url"
    done
}

function provisioning_get_civitai_files() {
    if [[ $# -lt 2 ]]; then return; fi
    local dir="$1"
    shift
    local files=("$@")

    mkdir -p "$dir"
    echo "Downloading ${#files[@]} CivitAI file(s) → $dir..."

    for entry in "${files[@]}"; do
        local url="${entry%%|*}"
        local filename="${entry##*|}"
        local auth_header=""
        if [[ -n "$CIVITAI_TOKEN" ]]; then
            auth_header="--header=Authorization: Bearer $CIVITAI_TOKEN"
        fi
        echo "→ $filename"
        wget $auth_header -nc --show-progress -O "${dir}/${filename}" "$url" || echo "[!] Download failed: $filename"
    done
}

function provisioning_install_instaraw_deps() {
    if [[ -d "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW" ]]; then
        echo "Installing ComfyUI_INSTARAW requirements..."
        pip install --no-cache-dir -r "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW/requirements.txt" || echo "[!] InstaRAW deps failed"
        echo "✅ InstaRAW dependencies installed"
    else
        echo "⚠️  ComfyUI_INSTARAW not found — skipping deps"
    fi
}

# Запуск provisioning если не отключен
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi