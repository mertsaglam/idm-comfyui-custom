cd /ComfyUI

for dir in custom_nodes/*/; do
 if [ -d "$dir" ]; then
  echo "Entering module: $dir"
  (cd $dir && pip install -r requirements.txt)
 fi
done
