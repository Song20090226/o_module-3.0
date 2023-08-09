TMPDIR_FOR_VERIFY="$TMPDIR/.vunzip"
mkdir -p "$TMPDIR_FOR_VERIFY"

abort_verify() {
  ui_print "*********************************************************"
  ui_print "! $1"
  ui_print "! This zip may be corrupted, please try downloading again"
  abort    "*********************************************************"
}

# extract <zip> <file> <target dir> <junk paths>
extract() {
  zip=$1
  file=$2
  dir=$3
  junk_paths=$4
  [ -z "$junk_paths" ] && junk_paths=false
  opts="-o"
  [ $junk_paths = true ] && opts="-oj"

  file_path=""
  hash_path=""
  if [ $junk_paths = true ]; then
    file_path="$dir/$(basename "$file")"
    hash_path="$TMPDIR_FOR_VERIFY/$(basename "$file").@onan1st_hack"
  else
    file_path="$dir/$file"
    hash_path="$TMPDIR_FOR_VERIFY/$file.@onan1st_hack"
  fi

  unzip $opts "$zip" "$file" -d "$dir" >&2
  [ -f "$file_path" ] || abort_verify "$file not exists"

  unzip $opts "$zip" "$file.@onan1st_hack" -d "$TMPDIR_FOR_VERIFY" >&2
  [ -f "$hash_path" ] || abort_verify "$file.@onan1st_hack not exists"

  (echo "$(cat "$hash_path")  $file_path" | sha512sum -c -s -) || abort_verify "Failed to verify $file"
  ui_print "- Verified $file" >&1
}