#!/bin/bash

# Configuration
SRC_DIR="src"
DST_DIR="dst"
CSS_FILE="css/style.css"
HEADER_FILE="src/_header.html"
FOOTER_FILE="src/_footer.html"

# Create destination directory and CSS directory
mkdir -p "$DST_DIR/css"

# Counters for reporting
total=0
success=0
failed=0

echo "Starting conversion of .org files to HTML..."

# Find and process all .org files
while IFS= read -r -d '' file; do
	((total++))

	# Calculate output file path
	echo "$file"
	relative_file="${file#$SRC_DIR/}"
	relative_file="${relative_file#./}" # Remove leading ./
	output_file="$DST_DIR/${relative_file%.org}.html"
	output_dir="$(dirname "$output_file")"

	# Extract page title from .org file
	page_title=""
	if [ -f "$file" ]; then
		# Try to get title from #+TITLE: line first
		page_title=$(grep -m 1 "^#+TITLE:" "$file" | sed 's/^#+TITLE: *//')
		
		# If no #+TITLE found, try to get first heading
		if [ -z "$page_title" ]; then
			page_title=$(grep -m 1 "^\\* " "$file" | sed 's/^\\* *//')
		fi
		
		# If still no title, use filename without extension
		if [ -z "$page_title" ]; then
			page_title=$(basename "$file" .org)
		fi
	fi

	# Extract tags from FILETAGS line
	file_tags=$(grep -m 1 "^#+FILETAGS:" "$file" | sed 's/^#+FILETAGS: *//')
	metadata_flags=""
	if [ -n "$file_tags" ]; then
		# Convert space-separated tags to individual --metadata flags
		for tag in $file_tags; do
			metadata_flags="$metadata_flags --metadata keywords:$tag"
		done
	fi

	# Format title: if it already contains "Carlos", just use it as-is, otherwise add prefix
	if [[ "$page_title" == *"Carlos"* ]]; then
		full_title="$page_title"
	else
		full_title="Carlos Vigil-Vásquez - $page_title"
	fi

	# Calculate relative path from output file to root
	output_relative_dir="$(dirname "$relative_file")"
	
	# Count directory depth and build root path
	if [ "$output_relative_dir" = "." ]; then
		depth=0  # File is at dst root
		root_path=""
	else
		# Count slashes to determine depth
		depth=$(echo "${output_relative_dir}/" | awk -F'/' '{print NF-1}')
		# Build root path
		root_path=""
		for ((i=0; i<depth; i++)); do
			root_path="${root_path}../"
		done
	fi
	
	# Create relative path for CSS
	css_relative_path="${root_path}css/style.css"

	# Create temporary header with corrected links and page title
	temp_header=$(mktemp)
	
	# Use different sed syntax for macOS
	if [ "$root_path" = "" ]; then
		# For root level files
		sed \
		    -e 's|href="/favicon.png"|href="favicon.png"|g' \
		    -e 's|href="/css/style.css"||g' \
		    -e "s|Page Title|$full_title|g" \
		    "$HEADER_FILE" > "$temp_header"
	else
		# For files in subdirectories
		sed \
		    -e "s|href=\"/favicon.png\"|href=\"${root_path}favicon.png\"|g" \
		    -e 's|href="/css/style.css"||g' \
		    -e "s|href=\"index.html\"|href=\"${root_path}index.html\"|g" \
		    -e "s|href=\"blog.html\"|href=\"${root_path}blog.html\"|g" \
		    -e "s|href=\"about.html\"|href=\"${root_path}about.html\"|g" \
		    -e "s|href=\"now.html\"|href=\"${root_path}now.html\"|g" \
		    -e "s|Page Title|$full_title|g" \
		    "$HEADER_FILE" > "$temp_header"
	fi

	# Create output directory if needed
	mkdir -p "$output_dir"

	echo "Converting: $file -> $output_file"
	echo "  Page title: '$full_title'"
	echo "  Relative dir: '$output_relative_dir', Depth: $depth, Root path: '$root_path'"
	echo "  CSS path: '$css_relative_path'"
	if [ -n "$file_tags" ]; then
		echo "  Tags: '$file_tags'"
	fi

	# Run pandoc with custom template, corrected header, CSS path, and tags metadata
	if pandoc -s \
		--template="$SRC_DIR/template.html" \
		-c "$css_relative_path" \
		$metadata_flags \
		-B "$temp_header" \
		-A "$FOOTER_FILE" \
		"$file" \
		-o "$output_file" 2>/dev/null; then
		((success++))
		echo "  ✓ Success"
	else
		((failed++))
		echo "  ✗ Failed (continuing...)"
	fi

	# Clean up temporary file
	rm "$temp_header"

done < <(find "$SRC_DIR" -name "*.org" -type f -print0)

echo ""
echo "Conversion complete!"
echo "Total files: $total"
echo "Successful: $success"
echo "Failed: $failed"

# Exit with error code only if ALL files failed
if [ "$success" -eq 0 ] && [ "$total" -gt 0 ]; then
	exit 1
fi
