THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for path in $THIS_DIR/../../idk_*; do
    if [ -d "$path" ]; then
        cd "${path}" && git add . && git commit -m "auto commit" && git push 
    fi
done
