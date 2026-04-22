#!/bin/bash
set -e
source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"
LOG_FILE="${WORKSPACE}/provisioning.log"
STATUS_FILE="/tmp/download_status.log"

# LOGGING
exec > >(tee -a "$LOG_FILE") 2>&1
> "$STATUS_FILE"

echo "=== MV-Private FULL Setup v2 ==="

# ============================================
# APT & PIP
# ============================================
apt-get update && apt-get install -y exiftool aria2 git
pip install --no-cache-dir lpips mediapipe==0.10.14

# ============================================
# HELPERS
# ============================================
record_status() {
    echo "$1|$2|$3" >> "$STATUS_FILE"
}

# ============================================
# DOWNLOAD CORE (ARIA2 + RETRY + SKIP)
# ============================================

download_file() {
    local url="$1"
    local dir="$2"

    mkdir -p "$dir"

    local filename=$(basename "${url%%\?*}")
    local full_path="$dir/$filename"

    if [[ -f "$full_path" ]]; then
        echo "  → $filename already exists ✅"
        record_status "$filename" "OK" "cached"
        return
    fi

    local success=0
    local err=""

    for attempt in 1 2 3; do
        echo "  → downloading $filename (attempt $attempt)..."

        aria2c -x 8 -s 8 \
            --max-tries=1 \
            --summary-interval=1 \
            --console-log-level=warn \
            -d "$dir" \
            -o "$filename" \
            "$url"

        if [[ -f "$full_path" ]]; then
            echo "  → done ✅"
            record_status "$filename" "OK" "downloaded"
            success=1
            break
        else
            err="failed attempt $attempt"
        fi
    done

    if [[ $success -eq 0 ]]; then
        echo "  → failed ❌ ($err)"
        record_status "$filename" "FAIL" "$err"
    fi
}

# ============================================
# GENERIC DOWNLOADERS
# ============================================

provisioning_get_files() {
    local dir="$1"
    shift
    local files=("$@")

    echo "Downloading ${#files[@]} files → $dir"

    for url in "${files[@]}"; do
        download_file "$url" "$dir"
    done
}

provisioning_get_civitai_files() {
    local dir="$1"
    shift
    local files=("$@")

    mkdir -p "$dir"

    for entry in "${files[@]}"; do
        local url="${entry%%|*}"
        local filename="${entry##*|}"
        local full_path="$dir/$filename"

        if [[ -f "$full_path" ]]; then
            echo "  → $filename already exists ✅"
            record_status "$filename" "OK" "cached"
            continue
        fi

        aria2c -x 8 -s 8 \
            --max-tries=3 \
            -d "$dir" \
            -o "$filename" \
            "$url" || record_status "$filename" "FAIL" "civitai download failed"

        if [[ -f "$full_path" ]]; then
            record_status "$filename" "OK" "downloaded"
        fi
    done
}

# ============================================
# NODES
# ============================================
mkdir -p "${COMFYUI_DIR}/custom_nodes"
cd "${COMFYUI_DIR}/custom_nodes"

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

for repo in "${NODES[@]}"; do
    dir="${repo##*/}"

    if [[ -d "$dir" ]]; then
        echo "Updating $dir"
        (cd "$dir" && git pull || true)
    else
        echo "Cloning $dir"
        git clone "$repo" --recursive || true
    fi

    if [[ -f "$dir/requirements.txt" ]]; then
        pip install --no-cache-dir -r "$dir/requirements.txt" || true
    fi

done

# ============================================
# MODEL ARRAYS (ORIGINAL)
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
# DOWNLOAD ALL
# ============================================

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
	
# ============================================
# FINAL CHECK
# ============================================

echo ""
echo "========== DOWNLOAD CHECK =========="
while IFS='|' read -r file status msg; do
    if [[ "$status" == "OK" ]]; then
        echo "$file → ✅ ($msg)"
    else
        echo "$file → ❌ ($msg)"
    fi
done < "$STATUS_FILE"

echo "===================================="

echo "✅ FULL provisioning V2 complete"
