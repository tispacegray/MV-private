#!/bin/bash
set -e
source /venv/main/bin/activate

WORKSPACE=${WORKSPACE:-/workspace}
COMFYUI_DIR="${WORKSPACE}/ComfyUI"
LOG_FILE="${WORKSPACE}/provisioning.log"

# Tee all output to log file
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== MV-Private ComfyUI Setup ==="
echo "=== InstaRAW + WAN 2.2 + FLUX Kontext + SDXL ==="
echo "=== Log: $LOG_FILE ==="

# ============================================
# APT & PIP PACKAGES
# ============================================

APT_PACKAGES=(
    "exiftool"
)

PIP_PACKAGES=(
    "lpips"
    "mediapipe"
)

# ============================================
# CUSTOM NODES
# ============================================

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/tispacegray/comfyui_controlnet_aux"
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

CHECKPOINTS=()

CHECKPOINTS_CIVITAI=(
    "https://civitai.red/api/download/models/2155386?type=Model&format=SafeTensor&size=pruned&fp=fp16|lustifySDXLNSFW_ggwpV7.safetensors"
)

TEXT_ENCODERS=(
    "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors"
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors"
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors"
)

# VAE: url|output_filename format for explicit naming
VAE_MODELS=(
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors|wan_2.1_vae.safetensors"
    "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/ae.safetensors|flux_ae.safetensors"
    "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors|ae.safetensors"
)

UPSCALE_MODELS=(
    "https://huggingface.co/Kim2091/UltraSharpV2/resolve/0d73a3fcc798ad4bc612db25bd30c18680265809/4x-UltraSharpV2.pth"
    "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth"
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth"
)

# Loras that go directly into models/loras/
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

CONTROLNET_MODELS=(
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors"
)

# Clip Vision for IPAdapter — url|filename format (server returns generic "model.safetensors")
CLIP_VISION_MODELS=(
    "https://huggingface.co/h94/IP-Adapter/resolve/main/models/image_encoder/model.safetensors|CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors"
)

IPADAPTER_MODELS=(
    "https://huggingface.co/h94/IP-Adapter/resolve/main/sdxl_models/ip-adapter-plus-face_sdxl_vit-h.safetensors"
)

# ============================================
# PRIVATE ASSETS (HuggingFace private dataset)
# ============================================
PRIVATE_HF_REPO="RockyBeerboa/mv-private-assets"

### ─────────────────────────────────────────────
### DO NOT EDIT BELOW UNLESS YOU KNOW WHAT YOU ARE DOING
### ─────────────────────────────────────────────

function provisioning_start() {
    echo ""
    echo "##############################################"
    echo "#   MV-Private Setup                         #"
    echo "#   InstaRAW + WAN 2.2 + FLUX + SDXL        #"
    echo "##############################################"
    echo ""

    provisioning_get_apt_packages
    provisioning_install_base_reqs
    provisioning_get_nodes
    provisioning_patch_mediapipe
    provisioning_get_pip_packages

    provisioning_get_files \
        "${COMFYUI_DIR}/models/diffusion_models" \
        "${DIFFUSION_MODELS[@]}"

    provisioning_get_civitai_files \
        "${COMFYUI_DIR}/models/checkpoints/SDXL" \
        "${CHECKPOINTS_CIVITAI[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/text_encoders" \
        "${TEXT_ENCODERS[@]}"

    # VAE with explicit output filenames
    provisioning_get_named_files \
        "${COMFYUI_DIR}/models/vae" \
        "${VAE_MODELS[@]}"

    provisioning_get_files \
        "${COMFYUI_DIR}/models/upscale_models" \
        "${UPSCALE_MODELS[@]}"

    # Loras root folder
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORAS[@]}"

    # DMD2 → loras/SDXL/
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/SDXL" \
        "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora_fp16.safetensors"

    # WAN 2.1 lora → loras/Wan/
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/Wan" \
        "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors"

    # WAN 2.2 Lenovo lora — special: filename has parentheses so we rename
    mkdir -p "${COMFYUI_DIR}/models/loras/Wan/2.2"
    if [[ ! -f "${COMFYUI_DIR}/models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" ]]; then
        echo "→ Wan2.2Lenovo.safetensors"
        wget --header="Authorization: Bearer $HF_TOKEN" \
            "https://huggingface.co/Danrisi/LenovoWan/resolve/main/Lenovo.safetensors" \
            -O "${COMFYUI_DIR}/models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" \
            && echo "  ✅ Done: Wan2.2Lenovo.safetensors" \
            || echo "[!] Download failed: Wan2.2Lenovo.safetensors"
    else
        echo "  ✅ Already exists: Wan2.2Lenovo.safetensors"
    fi

    provisioning_get_civitai_files \
        "${COMFYUI_DIR}/models/loras" \
        "${LORAS_CIVITAI[@]}"

    # ControlNet with full path
    provisioning_get_files \
        "${COMFYUI_DIR}/models/controlnet/SDXL/controlnet-union-sdxl-1.0" \
        "${CONTROLNET_MODELS[@]}"

    # Clip Vision for IPAdapter (named: server returns generic model.safetensors)
    provisioning_get_named_files \
        "${COMFYUI_DIR}/models/clip_vision" \
        "${CLIP_VISION_MODELS[@]}"

    # IPAdapter weights (PLUS FACE for SDXL portraits)
    provisioning_get_files \
        "${COMFYUI_DIR}/models/ipadapter" \
        "${IPADAPTER_MODELS[@]}"

    provisioning_get_private_assets

    provisioning_install_instaraw_deps

    provisioning_verify

    echo ""
    echo "✅ Setup complete → Starting ComfyUI..."
    echo ""
}

function provisioning_patch_mediapipe() {
    echo "Patching comfyui_controlnet_aux for mediapipe 0.10.x compatibility..."
 
    local FILE="${COMFYUI_DIR}/custom_nodes/comfyui_controlnet_aux/src/custom_controlnet_aux/mediapipe_face/mediapipe_face_common.py"
 
    if [[ ! -f "$FILE" ]]; then
        echo "⚠️  mediapipe_face_common.py not found, skipping patch"
        return
    fi
 
    # Download face_landmarker.task if not found
    if [[ ! -f "${COMFYUI_DIR}/face_landmarker.task" ]]; then
        echo "→ Downloading face_landmarker.task..."
        wget -q -O "${COMFYUI_DIR}/face_landmarker.task" \
            "https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/1/face_landmarker.task" \
            && echo "  ✅ face_landmarker.task" || echo "  [!] Failed to download face_landmarker.task"
    else
        echo "  ✅ face_landmarker.task already exists"
    fi
 
    # retry
    if grep -q "_LandmarkStub" "$FILE"; then
        echo "  ✅ mediapipe patch already applied, skipping"
        return
    fi
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

# Download files — filename taken from server (content-disposition)
function provisioning_get_files() {
    if [[ $# -lt 2 ]]; then return; fi
    local dir="$1"
    shift
    local files=("$@")

    mkdir -p "$dir"
    echo "Downloading ${#files[@]} file(s) → $dir..."

    for url in "${files[@]}"; do
        echo "→ $(basename "$url")"
        if [[ -n "$HF_TOKEN" && "$url" =~ huggingface\.co ]]; then
            wget --header="Authorization: Bearer $HF_TOKEN" -nc --content-disposition --show-progress -e dotbytes=4M -P "$dir" "$url" || echo "[!] Download failed: $url"
        else
            wget -nc --content-disposition --show-progress -e dotbytes=4M -P "$dir" "$url" || echo "[!] Download failed: $url"
        fi
    done
}

# Download files with explicit output filename (url|filename format)
function provisioning_get_named_files() {
    if [[ $# -lt 2 ]]; then return; fi
    local dir="$1"
    shift
    local files=("$@")

    mkdir -p "$dir"
    echo "Downloading ${#files[@]} named file(s) → $dir..."

    for entry in "${files[@]}"; do
        local url="${entry%%|*}"
        local filename="${entry##*|}"
        local dest="${dir}/${filename}"
        echo "→ $filename"
        if [[ -f "$dest" ]]; then
            echo "  ✅ Already exists, skipping"
            continue
        fi
        if [[ -n "$HF_TOKEN" && "$url" =~ huggingface\.co ]]; then
            wget --header="Authorization: Bearer $HF_TOKEN" --show-progress -O "$dest" "$url" \
                && echo "  ✅ Done" || echo "[!] Download failed: $filename"
        else
            wget --show-progress -O "$dest" "$url" \
                && echo "  ✅ Done" || echo "[!] Download failed: $filename"
        fi
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
        local dest="${dir}/${filename}"
        echo "→ $filename"
        if [[ -f "$dest" ]]; then
            echo "  ✅ Already exists, skipping"
            continue
        fi
        if [[ -n "$CIVITAI_TOKEN" ]]; then
            # curl drops Authorization on cross-domain redirects by default (correct behaviour:
            # auth goes to civitai only, NOT to the Cloudflare R2 CDN redirect)
            curl -L --progress-bar --fail \
                -H "Authorization: Bearer $CIVITAI_TOKEN" \
                -o "$dest" "$url" \
                && echo "  ✅ Done" || { rm -f "$dest"; echo "[!] Download failed: $filename"; }
        else
            curl -L --progress-bar --fail \
                -o "$dest" "$url" \
                && echo "  ✅ Done" || { rm -f "$dest"; echo "[!] Download failed: $filename"; }
        fi
    done
}

function provisioning_get_private_assets() {
    if [[ -z "$HF_TOKEN" ]]; then
        echo "⚠️  HF_TOKEN not set — skipping private assets"
        return
    fi

    echo "Downloading private assets from HuggingFace..."

    # LoRA
    mkdir -p "${COMFYUI_DIR}/models/loras"
    if [[ ! -f "${COMFYUI_DIR}/models/loras/detailed_nipples.safetensors" ]]; then
        echo "→ detailed_nipples.safetensors"
        wget --header="Authorization: Bearer $HF_TOKEN" --show-progress \
            "https://huggingface.co/datasets/${PRIVATE_HF_REPO}/resolve/main/loras/detailed_nipples.safetensors" \
            -O "${COMFYUI_DIR}/models/loras/detailed_nipples.safetensors" \
            && echo "  ✅ Done" || echo "[!] Failed: detailed_nipples"
    else
        echo "  ✅ Already exists: detailed_nipples.safetensors"
    fi

    # Ultralytics bbox models
    mkdir -p "${COMFYUI_DIR}/models/ultralytics/bbox"
    echo "→ ultralytics/bbox..."
    python3 - <<EOF
import os, requests
headers = {"Authorization": f"Bearer ${HF_TOKEN}"}
api = "https://huggingface.co/api/datasets/${PRIVATE_HF_REPO}/tree/main/ultralytics/bbox"
r = requests.get(api, headers=headers)
files = [f["path"] for f in r.json() if f["type"] == "file"]
for path in files:
    fname = os.path.basename(path)
    dest = "${COMFYUI_DIR}/models/ultralytics/bbox/" + fname
    if os.path.exists(dest):
        print(f"  ✅ Already exists: {fname}")
        continue
    url = f"https://huggingface.co/datasets/${PRIVATE_HF_REPO}/resolve/main/{path}"
    print(f"  → {fname}")
    resp = requests.get(url, headers=headers, stream=True)
    with open(dest, "wb") as f:
        for chunk in resp.iter_content(chunk_size=8192):
            f.write(chunk)
    print(f"  ✅ Done: {fname}")
EOF

    # ComfyUI_INSTARAW node — recursive download
    if [[ ! -f "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW/nodes/__init__.py" ]] && \
       [[ ! -f "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW/nodes/image_processing.py" ]]; then
        echo "→ ComfyUI_INSTARAW node (recursive)..."
        mkdir -p "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW"
        python3 - <<EOF
import os, requests

headers = {"Authorization": f"Bearer ${HF_TOKEN}"}
REPO = "${PRIVATE_HF_REPO}"
LOCAL_BASE = "${COMFYUI_DIR}/custom_nodes/ComfyUI_INSTARAW"

def download_recursive(hf_path, local_base):
    url = f"https://huggingface.co/api/datasets/{REPO}/tree/main/{hf_path}"
    r = requests.get(url, headers=headers)
    for item in r.json():
        if item["type"] == "file":
            rel = os.path.relpath(item["path"], "ComfyUI_INSTARAW")
            dest = os.path.join(local_base, rel)
            os.makedirs(os.path.dirname(dest), exist_ok=True)
            if os.path.exists(dest):
                continue
            file_url = f"https://huggingface.co/datasets/{REPO}/resolve/main/{item['path']}"
            resp = requests.get(file_url, headers=headers, stream=True)
            with open(dest, "wb") as f:
                for chunk in resp.iter_content(chunk_size=8192):
                    f.write(chunk)
            print(f"  ✅ {rel}")
        elif item["type"] == "directory":
            download_recursive(item["path"], local_base)

download_recursive("ComfyUI_INSTARAW", LOCAL_BASE)
print("INSTARAW download complete!")
EOF
    else
        echo "  ✅ ComfyUI_INSTARAW already exists, skipping"
    fi
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

function check_file() {
    local path="$1"
    local label="$2"
    if [[ -f "$path" ]]; then
        local size
        size=$(du -h "$path" | cut -f1)
        echo "  ✅ $label ($size)"
    else
        echo "  ❌ $label — MISSING"
    fi
}

function provisioning_verify() {
    echo ""
    echo "=============================================="
    echo "  VERIFICATION"
    echo "=============================================="

    echo ""
    echo "📁 Diffusion Models:"
    check_file "${COMFYUI_DIR}/models/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors" "WAN 2.2 T2V Low Noise"
    check_file "${COMFYUI_DIR}/models/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors" "WAN 2.2 T2V High Noise"
    check_file "${COMFYUI_DIR}/models/diffusion_models/z_image_turbo_bf16.safetensors" "Z-Image Turbo"
    check_file "${COMFYUI_DIR}/models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" "FLUX1 Kontext"

    echo ""
    echo "📁 Checkpoints:"
    check_file "${COMFYUI_DIR}/models/checkpoints/SDXL/lustifySDXLNSFW_ggwpV7.safetensors" "Lustify SDXL NSFW v7"

    echo ""
    echo "📁 Text Encoders:"
    check_file "${COMFYUI_DIR}/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "UMT5 XXL FP8"
    check_file "${COMFYUI_DIR}/models/text_encoders/qwen_3_4b.safetensors" "Qwen 3 4B"
    check_file "${COMFYUI_DIR}/models/text_encoders/clip_l.safetensors" "CLIP L"
    check_file "${COMFYUI_DIR}/models/text_encoders/t5xxl_fp16.safetensors" "T5XXL FP16"

    echo ""
    echo "📁 VAE:"
    check_file "${COMFYUI_DIR}/models/vae/wan_2.1_vae.safetensors" "WAN 2.1 VAE"
    check_file "${COMFYUI_DIR}/models/vae/flux_ae.safetensors" "FLUX AE VAE"
    check_file "${COMFYUI_DIR}/models/vae/ae.safetensors" "Z-Image AE VAE"

    echo ""
    echo "📁 Upscale Models:"
    check_file "${COMFYUI_DIR}/models/upscale_models/4x-UltraSharpV2.pth" "4x UltraSharp V2"
    check_file "${COMFYUI_DIR}/models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth" "4x NMKD Superscale"
    check_file "${COMFYUI_DIR}/models/upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth" "1x ITF SkinDiffDetail"

    echo ""
    echo "📁 LoRAs:"
    check_file "${COMFYUI_DIR}/models/loras/SDXL/dmd2_sdxl_4step_lora_fp16.safetensors" "DMD2 SDXL 4step"
    check_file "${COMFYUI_DIR}/models/loras/Instareal_low.safetensors" "Instareal Low"
    check_file "${COMFYUI_DIR}/models/loras/Instareal_high.safetensors" "Instareal High"
    check_file "${COMFYUI_DIR}/models/loras/Wan/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" "WAN 2.1 Lightx2v"
    check_file "${COMFYUI_DIR}/models/loras/Instagirlv2.5-LOW.safetensors" "Instagirl v2.5 LOW"
    check_file "${COMFYUI_DIR}/models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" "WAN 2.2 Lenovo"
    check_file "${COMFYUI_DIR}/models/loras/Instagirlv2.5-HIGH.safetensors" "Instagirl v2.5 HIGH"
    check_file "${COMFYUI_DIR}/models/loras/lady_hand.safetensors" "Lady Hand"
    check_file "${COMFYUI_DIR}/models/loras/real_feet.safetensors" "Real Feet"
    check_file "${COMFYUI_DIR}/models/loras/kontext_big_breasts_and_butts.safetensors" "Kontext Big"
    check_file "${COMFYUI_DIR}/models/loras/detailed_nipples.safetensors" "Detailed Nipples (private)"

    echo ""
    echo "📁 ControlNet:"
    check_file "${COMFYUI_DIR}/models/controlnet/SDXL/controlnet-union-sdxl-1.0/diffusion_pytorch_model_promax.safetensors" "ControlNet Union SDXL Promax"

    echo ""
    echo "📁 Clip Vision:"
    check_file "${COMFYUI_DIR}/models/clip_vision/CLIP-ViT-H-14-laion2B-s32B-b79K.safetensors" "CLIP ViT-H-14 (IPAdapter SDXL)"

    echo ""
    echo "📁 IPAdapter:"
    check_file "${COMFYUI_DIR}/models/ipadapter/ip-adapter-plus-face_sdxl_vit-h.safetensors" "IPAdapter PLUS FACE SDXL"

    echo ""
    echo "📁 Custom Nodes:"
    for node in ComfyUI-Manager comfyui_controlnet_aux ComfyUI-Impact-Pack rgthree-comfy ComfyUI_UltimateSDUpscale ComfyUI_essentials a-person-mask-generator ComfyUI-Impact-Subpack ComfyUI-Easy-Use ComfyUI-KJNodes ComfyUI-Inpaint-CropAndStitch was-node-suite-comfyui ComfyUI_IPAdapter_plus RES4LYF masquerade-nodes-comfyui ComfyUI-Batch-Process ComfyUI-RMBG comfyui_segment_anything ComfyUI-Color-Matcher ComfyUI_Swwan ComfyUI-SeedVR2_VideoUpscaler Comfyui_LG_Tools ComfyUI_Steudio ComfyLiterals ComfyUI_JPS-Nodes ComfyUI_INSTARAW; do
        if [[ -d "${COMFYUI_DIR}/custom_nodes/$node" ]]; then
            echo "  ✅ $node"
        else
            echo "  ❌ $node — MISSING"
        fi
    done

    echo ""
    echo "📁 face_landmarker.task"
    check_file "${COMFYUI_DIR}/face_landmarker.task" "face_landmarker.task"

    echo ""
    echo "📦 Package versions:"
    /venv/main/bin/python3 -c "import lpips; print(f'  lpips: {lpips.__version__}')" 2>/dev/null || echo "  lpips: not found"
    /venv/main/bin/python3 -c "import mediapipe; print(f'  mediapipe: {mediapipe.__version__}')" 2>/dev/null || echo "  mediapipe: not found"
    exiftool -ver 2>/dev/null | xargs -I{} echo "  exiftool: {}" || echo "  exiftool: not found"

    echo ""
    echo "=============================================="
    echo "  Log saved to: $LOG_FILE"
    echo "=============================================="
}

# Run provisioning unless disabled
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
