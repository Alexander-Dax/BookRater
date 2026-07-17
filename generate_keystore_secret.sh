#!/bin/bash

# Script to generate base64-encoded keystore for GitHub Secrets
# Run this from the book_rater_app directory

set -e

echo "=========================================="
echo "GitHub Keystore Secret Generator"
echo "=========================================="
echo ""

KEYSTORE_FILE="android/app/upload-keystore.jks"
OUTPUT_FILE="keystore_base64.txt"

# Check if keystore exists
if [ ! -f "$KEYSTORE_FILE" ]; then
    echo "❌ ERROR: Keystore file not found at: $KEYSTORE_FILE"
    echo ""
    echo "Please make sure you are running this script from the book_rater_app directory"
    echo "and that the keystore file exists."
    exit 1
fi

echo "✅ Found keystore file: $KEYSTORE_FILE"
echo ""

# Get file size
KEYSTORE_SIZE=$(ls -lh "$KEYSTORE_FILE" | awk '{print $5}')
echo "📦 Keystore size: $KEYSTORE_SIZE"
echo ""

# Generate base64
echo "🔄 Generating base64 encoding..."
base64 -w 0 "$KEYSTORE_FILE" > "$OUTPUT_FILE"

if [ ! -f "$OUTPUT_FILE" ]; then
    echo "❌ ERROR: Failed to create output file"
    exit 1
fi

# Get output size
OUTPUT_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')
echo "✅ Base64 file created: $OUTPUT_FILE ($OUTPUT_SIZE)"
echo ""

# Verify the base64 is valid
echo "🔍 Verifying base64 encoding..."
if cat "$OUTPUT_FILE" | base64 -d > /tmp/test-keystore.jks 2>/dev/null; then
    TEST_SIZE=$(ls -lh /tmp/test-keystore.jks | awk '{print $5}')
    echo "✅ Base64 encoding is valid! (decoded size: $TEST_SIZE)"
    rm /tmp/test-keystore.jks
else
    echo "❌ ERROR: Base64 encoding verification failed!"
    exit 1
fi

echo ""
echo "=========================================="
echo "Next Steps:"
echo "=========================================="
echo ""
echo "1. Open the file: $OUTPUT_FILE"
echo ""
echo "2. Copy the ENTIRE content (one very long line)"
echo ""
echo "3. Go to your GitHub repository:"
echo "   Settings → Secrets and variables → Actions"
echo ""
echo "4. Click 'New repository secret'"
echo ""
echo "5. Add these secrets:"
echo ""
echo "   Name: KEYSTORE_BASE64"
echo "   Value: <paste the content from $OUTPUT_FILE>"
echo ""
echo "   Name: KEYSTORE_PASSWORD"
echo "   Value: bookreader2024"
echo ""
echo "   Name: KEY_PASSWORD"
echo "   Value: bookreader2024"
echo ""
echo "   Name: KEY_ALIAS"
echo "   Value: upload"
echo ""
echo "=========================================="
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Make sure to copy the ENTIRE content"
echo "   - Do NOT add any extra spaces or newlines"
echo "   - The secret should be one continuous line"
echo ""
echo "✅ Done! The base64 keystore is ready in: $OUTPUT_FILE"
echo ""
