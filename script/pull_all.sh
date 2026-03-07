THIS_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

for path in $THIS_DIR/../../idk_*; do
    if [ -d "$path" ]; then
        cd "${path}" && git pull
    fi
done
