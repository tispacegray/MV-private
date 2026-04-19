#!/bin/bash

# Full Setup Script - InstaRAW + WAN 2.2 + FLUX Kontext + SDXL
# For Jupyter Terminal with HuggingFace & CivitAI Authentication

# ============================================
# TOKENS CONFIGURATION
# ============================================

# Вставте ваш HuggingFace токен тут:
HF_TOKEN="PUT_YOUR_TOKEN_HERE"

# Вставте ваш CivitAI API ключ тут:
CIVITAI_TOKEN="PUT_YOUR_TOKEN_HERE"

# ============================================
# TOKENS VALIDATION
# ============================================

echo "=============================================="
echo "  Full Setup Installer"
echo "  InstaRAW + WAN 2.2 + FLUX + SDXL"
echo "=============================================="
echo ""

if [ -n "$HF_TOKEN" ] && [ "$HF_TOKEN" != "YOUR_HUGGINGFACE_TOKEN_HERE" ]; then
    echo "✅ HuggingFace token: ${HF_TOKEN:0:10}...${HF_TOKEN: -4}"
else
    echo "⚠️  HuggingFace token: NOT SET"
fi

if [ -n "$CIVITAI_TOKEN" ] && [ "$CIVITAI_TOKEN" != "YOUR_CIVITAI_API_KEY_HERE" ]; then
    echo "✅ CivitAI token: ${CIVITAI_TOKEN:0:6}...${CIVITAI_TOKEN: -4}"
else
    echo "⚠️  CivitAI token: NOT SET (CivitAI downloads will fail)"
fi

echo ""
echo "Total: 4 diffusion + 1 checkpoint + 4 text encoders + 3 VAE"
echo "       3 upscale + 10 loras + 1 controlnet + 22 custom nodes"
echo ""

# ============================================
# DOWNLOAD FUNCTIONS
# ============================================

# HuggingFace download with auth
download_hf() {
    local url=$1
    local output=$2
    local name=$3

    echo "[$name]"

    if [ -f "$output" ]; then
        echo "  ✅ Already exists, skipping..."
        return 0
    fi

    mkdir -p "$(dirname "$output")"

    if [ -n "$HF_TOKEN" ] && [ "$HF_TOKEN" != "YOUR_HUGGINGFACE_TOKEN_HERE" ]; then
        wget -c --header="Authorization: Bearer $HF_TOKEN" "$url" -O "$output"
    else
        wget -c "$url" -O "$output"
    fi

    if [ $? -eq 0 ]; then
        echo "  ✅ Done!"
        return 0
    else
        echo "  ❌ Failed!"
        return 1
    fi
}

# CivitAI download with auth
download_civitai() {
    local url=$1
    local output=$2
    local name=$3

    echo "[$name]"

    if [ -f "$output" ]; then
        echo "  ✅ Already exists, skipping..."
        return 0
    fi

    mkdir -p "$(dirname "$output")"

    if [ -n "$CIVITAI_TOKEN" ] && [ "$CIVITAI_TOKEN" != "YOUR_CIVITAI_API_KEY_HERE" ]; then
        curl -L --header "Authorization: Bearer $CIVITAI_TOKEN" "$url" -o "$output"
    else
        echo "  ⚠️  No CivitAI token, trying without auth..."
        curl -L "$url" -o "$output"
    fi

    if [ $? -eq 0 ]; then
        echo "  ✅ Done!"
        return 0
    else
        echo "  ❌ Failed!"
        return 1
    fi
}

cd /workspace/ComfyUI

# ============================================
# STEP 1: SYSTEM LIBRARIES
# ============================================

echo ""
echo "=== STEP 1: INSTALLING SYSTEM LIBRARIES ==="
echo ""

echo "[1/2] Installing exiftool..."
apt-get install -y exiftool
echo ""

echo "[2/2] Installing lpips..."
pip install lpips --break-system-packages
echo ""

# ============================================
# STEP 2: INSTARAW DEPENDENCIES
# ============================================

echo "=== STEP 2: INSTARAW NODE DEPENDENCIES ==="
echo ""

if [ -d "custom_nodes/ComfyUI_INSTARAW" ]; then
    echo "Installing ComfyUI_INSTARAW requirements..."
    pip install -r custom_nodes/ComfyUI_INSTARAW/requirements.txt --break-system-packages
    echo "✅ InstaRAW dependencies installed"
else
    echo "⚠️  ComfyUI_INSTARAW not found in custom_nodes/"
    echo "    Install the node first, then run this step manually:"
    echo "    pip install -r custom_nodes/ComfyUI_INSTARAW/requirements.txt --break-system-packages"
fi
echo ""

# ============================================
# STEP 3: DIFFUSION MODELS
# ============================================

echo "=== STEP 3: DIFFUSION MODELS ==="
echo ""

mkdir -p models/diffusion_models

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors" \
    "models/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors" \
    "1/4 WAN 2.2 T2V Low Noise 14B FP16"
echo ""

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors" \
    "models/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors" \
    "2/4 WAN 2.2 T2V High Noise 14B FP16"
echo ""

download_hf \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" \
    "models/diffusion_models/z_image_turbo_bf16.safetensors" \
    "3/4 Z-Image Turbo BF16"
echo ""

download_hf \
    "https://huggingface.co/Comfy-Org/flux1-kontext-dev_ComfyUI/resolve/main/split_files/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
    "models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" \
    "4/4 FLUX1 Dev Kontext FP8"
echo ""

# ============================================
# STEP 4: CHECKPOINTS
# ============================================

echo "=== STEP 4: CHECKPOINTS ==="
echo ""

mkdir -p models/checkpoints

download_hf \
    "https://huggingface.co/Kutches/XL/resolve/main/lustifySDXLNSFW_ggwpV7.safetensors" \
    "models/checkpoints/SDXL/lustifySDXLNSFW_ggwpV7.safetensors" \
    "1/1 Lustify SDXL NSFW v7"
echo ""

# ============================================
# STEP 5: TEXT ENCODERS
# ============================================

echo "=== STEP 5: TEXT ENCODERS ==="
echo ""

mkdir -p models/text_encoders

download_hf \
    "https://huggingface.co/chatpig/encoder/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    "models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
    "1/4 UMT5 XXL FP8"
echo ""

download_hf \
    "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
    "models/text_encoders/qwen_3_4b.safetensors" \
    "2/4 Qwen 3 4B"
echo ""

download_hf \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors" \
    "models/text_encoders/clip_l.safetensors" \
    "3/4 CLIP L"
echo ""

download_hf \
    "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp16.safetensors" \
    "models/text_encoders/t5xxl_fp16.safetensors" \
    "4/4 T5XXL FP16"
echo ""

# ============================================
# STEP 6: VAE
# ============================================

echo "=== STEP 6: VAE ==="
echo ""

mkdir -p models/vae

download_hf \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
    "models/vae/wan_2.1_vae.safetensors" \
    "1/3 WAN 2.1 VAE"
echo ""

download_hf \
    "https://huggingface.co/flux-safetensors/flux-safetensors/resolve/main/ae.safetensors" \
    "models/vae/flux_ae.safetensors" \
    "2/3 FLUX AE VAE"
echo ""

download_hf \
    "https://huggingface.co/Comfy-Org/Lumina_Image_2.0_Repackaged/resolve/main/split_files/vae/ae.safetensors" \
    "models/vae/ae.safetensors" \
    "3/3 Z-Image 2.0 VAE"
echo ""

# ============================================
# STEP 7: UPSCALE MODELS
# ============================================

echo "=== STEP 7: UPSCALE MODELS ==="
echo ""

mkdir -p models/upscale_models

download_hf \
    "https://huggingface.co/Kim2091/UltraSharpV2/resolve/0d73a3fcc798ad4bc612db25bd30c18680265809/4x-UltraSharpV2.pth" \
    "models/upscale_models/4x-UltraSharpV2.pth" \
    "1/3 4x UltraSharp V2"
echo ""

download_hf \
    "https://huggingface.co/gemasai/4x_NMKD-Superscale-SP_178000_G/resolve/main/4x_NMKD-Superscale-SP_178000_G.pth" \
    "models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth" \
    "2/3 4x NMKD Superscale"
echo ""

download_hf \
    "https://huggingface.co/uwg/upscaler/resolve/main/ESRGAN/1x-ITF-SkinDiffDetail-Lite-v1.pth" \
    "models/upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth" \
    "3/3 1x ITF SkinDiffDetail Lite"
echo ""

# ============================================
# STEP 8: LORAS
# ============================================

echo "=== STEP 8: LORAS ==="
echo ""

mkdir -p models/loras
mkdir -p models/loras/Wan/2.2

download_hf \
    "https://huggingface.co/tianweiy/DMD2/resolve/main/dmd2_sdxl_4step_lora_fp16.safetensors" \
    "models/loras/SDXL/dmd2_sdxl_4step_lora_fp16.safetensors" \
    "1/10 DMD2 SDXL 4step LoRA"
echo ""

download_hf \
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_low.safetensors" \
    "models/loras/Instareal_low.safetensors" \
    "2/10 Instareal Low"
echo ""

download_hf \
    "https://huggingface.co/Daverrrr75/Instareal/resolve/main/Instareal_high.safetensors" \
    "models/loras/Instareal_high.safetensors" \
    "3/10 Instareal High"
echo ""

download_hf \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
    "models/loras/Wan/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" \
    "4/10 WAN 2.1 T2V Lightx2v LoRA"
echo ""

download_hf \
    "https://huggingface.co/Osrivers/Instagirlv2.5-LOW.safetensors/resolve/main/Instagirlv2.5-LOW.safetensors" \
    "models/loras/Instagirlv2.5-LOW.safetensors" \
    "5/10 Instagirl v2.5 LOW"
echo ""

download_hf \
    "https://huggingface.co/TheRaf7/ultra-real-wan2.2/resolve/main/Lenovo(1).safetensors" \
    "models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" \
    "6/10 WAN 2.2 Lenovo LoRA"
echo ""

download_hf \
    "https://huggingface.co/allyourtech/instagirl/resolve/main/Instagirlv2.5-HIGH.safetensors" \
    "models/loras/Instagirlv2.5-HIGH.safetensors" \
    "7/10 Instagirl v2.5 HIGH"
echo ""

download_civitai \
    "https://civitai.com/api/download/models/550216?type=Model&format=SafeTensor" \
    "models/loras/lady_hand.safetensors" \
    "8/10 Lady Hand (CivitAI)"
echo ""

download_civitai \
    "https://civitai.com/api/download/models/238277?type=Model&format=SafeTensor" \
    "models/loras/real_feet.safetensors" \
    "9/10 Real Feet (CivitAI)"
echo ""

download_hf \
    "https://huggingface.co/BAZILEVS-BASED/kontext_big_breasts_and_butts/resolve/main/kontext_big_breasts_and_butts.safetensors" \
    "models/loras/kontext_big_breasts_and_butts.safetensors" \
    "10/10 Kontext Big LoRA"
echo ""

# ============================================
# STEP 9: CONTROLNET
# ============================================

echo "=== STEP 9: CONTROLNET ==="
echo ""

mkdir -p models/controlnet

download_hf \
    "https://huggingface.co/xinsir/controlnet-union-sdxl-1.0/resolve/main/diffusion_pytorch_model_promax.safetensors" \
    "models/controlnet/SDXL/controlnet-union-sdxl-1.0/diffusion_pytorch_model_promax.safetensors" \
    "1/1 ControlNet Union SDXL Promax"
echo ""

# ============================================
# STEP 10: CUSTOM NODES
# ============================================

echo "=== STEP 10: CUSTOM NODES ==="
echo ""

cd custom_nodes

declare -a nodes=(
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/ssitu/ComfyUI_UltimateSDUpscale"
    "https://github.com/cubiq/ComfyUI_essentials"
    "https://github.com/djbielejeski/a-person-mask-generator"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/yolain/ComfyUI-Easy-Use"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch.git"
    "https://github.com/WASasquatch/was-node-suite-comfyui.git"
    "https://github.com/cubiq/ComfyUI_IPAdapter_plus.git"
    "https://github.com/ClownsharkBatwing/RES4LYF.git"
    "https://github.com/BadCafeCode/masquerade-nodes-comfyui.git"
    "https://github.com/Zar4X/ComfyUI-Batch-Process.git"
    "https://github.com/1038lab/ComfyUI-RMBG.git"
    "https://github.com/storyicon/comfyui_segment_anything.git"
    "https://github.com/okdalto/ComfyUI-Color-Matcher.git"
    "https://github.com/aining2022/ComfyUI_Swwan.git"
    "https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git"
    "https://github.com/LAOGOU-666/Comfyui_LG_Tools.git"
    "https://github.com/Steudio/ComfyUI_Steudio.git"
    "https://github.com/M1kep/ComfyLiterals.git"
    "https://github.com/JPS-GER/ComfyUI_JPS-Nodes.git"
)

node_count=0
total_nodes=${#nodes[@]}

for repo in "${nodes[@]}"; do
    ((node_count++))
    node_name=$(basename "$repo" .git)
    echo "[$node_count/$total_nodes] Installing $node_name..."

    if [ -d "$node_name" ]; then
        cd "$node_name" && git pull && cd ..
    else
        git clone "$repo"
    fi
done

echo ""
echo "Installing node dependencies..."
echo ""

for node_dir in */; do
    if [ -f "${node_dir}requirements.txt" ]; then
        echo "  Installing requirements for ${node_dir}..."
        pip install -r "${node_dir}requirements.txt" --break-system-packages
    fi
    if [ -f "${node_dir}install.py" ]; then
        echo "  Running install.py for ${node_dir}..."
        cd "$node_dir" && python install.py && cd ..
    fi
done

cd ..

# ============================================
# VERIFICATION
# ============================================

echo ""
echo "=============================================="
echo "  INSTALLATION SUMMARY"
echo "=============================================="
echo ""

ok=0
fail=0

check() {
    if [ -f "$1" ]; then
        size=$(du -h "$1" | cut -f1)
        echo "  ✅ $2 ($size)"
        ((ok++))
    else
        echo "  ❌ $2 - MISSING"
        ((fail++))
    fi
}

echo "📁 Diffusion Models:"
check "models/diffusion_models/wan2.2_t2v_low_noise_14B_fp16.safetensors" "WAN 2.2 T2V Low Noise"
check "models/diffusion_models/wan2.2_t2v_high_noise_14B_fp16.safetensors" "WAN 2.2 T2V High Noise"
check "models/diffusion_models/z_image_turbo_bf16.safetensors" "Z-Image Turbo"
check "models/diffusion_models/flux1-dev-kontext_fp8_scaled.safetensors" "FLUX1 Kontext"

echo ""
echo "📁 Checkpoints:"
check "models/checkpoints/SDXL/lustifySDXLNSFW_ggwpV7.safetensors" "Lustify SDXL NSFW v7"

echo ""
echo "📁 Text Encoders:"
check "models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" "UMT5 XXL FP8"
check "models/text_encoders/qwen_3_4b.safetensors" "Qwen 3 4B"
check "models/text_encoders/clip_l.safetensors" "CLIP L"
check "models/text_encoders/t5xxl_fp16.safetensors" "T5XXL FP16"

echo ""
echo "📁 VAE:"
check "models/vae/wan_2.1_vae.safetensors" "WAN 2.1 VAE"
check "models/vae/flux_ae.safetensors" "FLUX AE VAE"
check "models/vae/ae.safetensors" "Z-Image AE VAE"

echo ""
echo "📁 Upscale Models:"
check "models/upscale_models/4x-UltraSharpV2.pth" "4x UltraSharp V2"
check "models/upscale_models/4x_NMKD-Superscale-SP_178000_G.pth" "4x NMKD Superscale"
check "models/upscale_models/1x-ITF-SkinDiffDetail-Lite-v1.pth" "1x ITF SkinDiffDetail"

echo ""
echo "📁 LoRAs:"
check "models/loras/SDXL/dmd2_sdxl_4step_lora_fp16.safetensors" "DMD2 SDXL 4step"
check "models/loras/Instareal_low.safetensors" "Instareal Low"
check "models/loras/Instareal_high.safetensors" "Instareal High"
check "models/loras/Wan/Wan21_T2V_14B_lightx2v_cfg_step_distill_lora_rank32.safetensors" "WAN 2.1 Lightx2v"
check "models/loras/Instagirlv2.5-LOW.safetensors" "Instagirl v2.5 LOW"
check "models/loras/Wan/2.2/Wan2.2Lenovo.safetensors" "WAN 2.2 Lenovo"
check "models/loras/Instagirlv2.5-HIGH.safetensors" "Instagirl v2.5 HIGH"
check "models/loras/lady_hand.safetensors" "Lady Hand"
check "models/loras/real_feet.safetensors" "Real Feet"
check "models/loras/kontext_big_breasts_and_butts.safetensors" "Kontext Big"

echo ""
echo "📁 ControlNet:"
check "models/controlnet/SDXL/controlnet-union-sdxl-1.0/diffusion_pytorch_model_promax.safetensors" "ControlNet Union SDXL Promax"

echo ""
echo "📁 Custom Nodes:"
for node_name in comfyui_controlnet_aux ComfyUI-Impact-Pack rgthree-comfy ComfyUI_UltimateSDUpscale ComfyUI_essentials a-person-mask-generator ComfyUI-Impact-Subpack ComfyUI-Easy-Use ComfyUI-KJNodes ComfyUI-Inpaint-CropAndStitch was-node-suite-comfyui ComfyUI_IPAdapter_plus RES4LYF masquerade-nodes-comfyui ComfyUI-Batch-Process ComfyUI-RMBG comfyui_segment_anything ComfyUI-Color-Matcher ComfyUI_Swwan ComfyUI-SeedVR2_VideoUpscaler Comfyui_LG_Tools ComfyUI_Steudio ComfyLiterals ComfyUI_JPS-Nodes; do
    if [ -d "custom_nodes/$node_name" ]; then
        echo "  ✅ $node_name"
        ((ok++))
    else
        echo "  ❌ $node_name - MISSING"
        ((fail++))
    fi
done

echo ""
echo "=============================================="
echo "📊 Results: ✅ $ok OK  |  ❌ $fail FAILED"
echo "=============================================="

if [ $fail -eq 0 ]; then
    echo ""
    echo "🎉 Everything installed successfully!"
else
    echo ""
    echo "⚠️  $fail items failed. Check errors above."
    echo ""
    echo "Common fixes:"
    echo "  - HF gated models: set HF_TOKEN and request access on HuggingFace"
    echo "  - CivitAI models: set CIVITAI_TOKEN at civitai.com/user/account"
    echo "  - Run script again - it will skip already downloaded files"
fi

echo ""
echo "Next steps:"
echo "  1. Restart ComfyUI"
echo "  2. Load your workflow"
echo "  3. Start generating!"
echo "=============================================="