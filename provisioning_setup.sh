#!/bin/bash
set -e
source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"

echo "=== MV-Private ComfyUI Setup ==="
echo "=== InstaRAW + WAN 2.2 + FLUX Kontext + SDXL ==="

# ============================================
# APT & PIP PACKAGES
# ============================================

APT_PACKAGES=(
    "exiftool"
)

PIP_PACKAGES=(
    "lpips"
    "mediapipe==0.10.14"
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
    "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/Kim2091/UltraSharpV2/resolve/0d73a3fcc798ad4bc612db25bd30c18680265809/4x-UltraSharpV2.pth"
    "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth"
)

LORAS=(
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_low.safetensors"
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_high.safetensors"
    "https://huggingface.co/Osrivers/Instagirlv2.5-LOW.safetensors/resolve/main/Instagirlv2.5-LOW.safetensors"
    "https://huggingface.co/allyourtech/instagirl/resolve/main/Instagirlv2.5-HIGH.safetensors"
    "https://huggingface.co/BAZILEVS-BASED/kontext_big_breasts_and_butts/resolve/main/kontext_big_breasts_and_butts.safetensors"
)

LORAS_CIVITAI=(
    "https://civitai.com/api/download/models/550216?type=Model&format=SafeTensor|lady_hand.safetensors"
    "https://civitai.com/api/download/models/238277?type=Model&format=SafeTensor|real_feet.safetensors"
)

# ============================================
# PRIVATE ASSETS
# ============================================
PRIVATE_HF_REPO="RockyBeerboa/mv-private-assets"

# ============================================
# CUSTOM DOWNLOAD FUNCTION (FIXED)
# ============================================

function download_hf() {
    local url="$1"
    local path="$2"
    local label="$3"

    local full_path="${COMFYUI_DIR}/${path}"
    local dir
    dir=$(dirname "$full_path")

    mkdir -p "$dir"

    echo "→ $label"

    if [[ -n "$HF_TOKEN" ]]; then
        wget --header="Authorization: Bearer $HF_TOKEN" \
            -nc --show-progress \
            -O "$full_path" "$url" \
            || echo "[!] Failed: $label"
    else
        wget -nc --show-progress \
            -O "$full_path" "$url" \
            || echo "[!] Failed: $label"
    fi
}

# ============================================
# MAIN
# ============================================

function provisioning_start() {

    provisioning_get_apt_packages
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_get_pip_packages

    provisioning_get_files "${COMFYUI_DIR}/models/diffusion_models" "${DIFFUSION_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/checkpoints/SDXL" "${CHECKPOINTS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/text_encoders" "${TEXT_ENCODERS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/vae" "${VAE_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/upscale_models" "${UPSCALE_MODELS[@]}"
    provisioning_get_files "${COMFYUI_DIR}/models/loras" "${LORAS[@]}"

    provisioning_get_civitai_files "${COMFYUI_DIR}/models/loras" "${LORAS_CIVITAI[@]}"

    # ============================================
    # CUSTOM FIXED DOWNLOADS
    # ============================================

    download_hf \
    "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora_fp16.safetensors" \
    "models/loras/SDXL/dmd2_sdxl_4step_lora_fp16.safetensors" \
    "1/10 DMD2 SDXL 4step LoRA"

    download_hf \
    "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/ae.safetensors" \
    "models/vae/flux_ae.safetensors" \
    "2/3 FLUX AE VAE"

    download_hf \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
    "models/loras/Wan/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
    "4/10 WAN 2.1 T2V Lightx2v LoRA"

    download_hf \
    "https://huggingface.co/TheRaf7/ultra-real-wan2.2/resolve/main/Lenovo(1).safetensors" \
    "models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" \
    "6/10 WAN 2.2 Lenovo LoRA"

    download_hf \
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors" \
    "models/controlnet/SDXL/controlnet-union-sdxl-1.0/diffusion_pytorch_model_promax.safetensors" \
    "1/1 ControlNet Union SDXL Promax"

    provisioning_get_private_assets
    provisioning_install_instaraw_deps

    echo "✅ Setup complete"
}

# ============================================
# EXISTING FUNCTIONS (UNCHANGED)
# ============================================

function provisioning_install_base_reqs() {
    cd "${COMFYUI_DIR}"
    if [[ -f requirements.txt ]]; then
        pip install --no-cache-dir -r requirements.txt
    fi
}

function provisioning_get_apt_packages() {
    apt-get update && apt-get install -y "${APT_PACKAGES[@]}"
}

function provisioning_get_pip_packages() {
    pip install --no-cache-dir "${PIP_PACKAGES[@]}"
}

function provisioning_get_nodes() {
    mkdir -p "${COMFYUI_DIR}/custom_nodes"
    cd "${COMFYUI_DIR}/custom_nodes"

    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="./${dir}"

        if [[ -d "$path" ]]; then
            (cd "$path" && git pull --ff-only || true)
        else
            git clone "$repo" "$path" --recursive || true
        fi

        if [[ -f "${path}/requirements.txt" ]]; then
            pip install --no-cache-dir -r "${path}/requirements.txt" || true
        fi
    done
}

function provisioning_get_files() {
    local dir="$1"
    shift
    mkdir -p "$dir"
    for url in "$@"; do
        wget -nc --content-disposition -P "$dir" "$url" || true
    done
}

function provisioning_get_civitai_files() {
    local dir="$1"
    shift
    mkdir -p "$dir"
    for entry in "$@"; do
        local url="${entry%%|*}"
        local filename="${entry##*|}"
        wget -nc -O "${dir}/${filename}" "$url" || true
    done
}

function provisioning_get_private_assets() { :; }
function provisioning_install_instaraw_deps() { :; }

if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
