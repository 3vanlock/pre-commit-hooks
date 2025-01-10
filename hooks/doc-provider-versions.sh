#!/bin/bash
find ./clusters -type d -name crossplane-resources -print0 | while read -d $'\0' file
do
    provider_dir="$file/providers"
    content=""
    echo "# Crossplane Providers" > "$provider_dir/README.md"
    echo "## Upbound Providers\n| Provider Name | Version |\n| ---- | -------- |" > "$provider_dir/README.md"
    find $provider_dir -type f -name "*.yaml" -not -name "kustomization.yaml"  -print0 | while read -d $'\0' file
    do
        result=$(grep -E "xpkg.upbound.io/upbound/(.*)" $file)
        if [ -z "$result" ]; then
            continue
        fi
        result=$(echo $result | xargs)
        result=$(echo ${result:9})
        registry=$(echo ${result:0:23})
        package=$(echo ${result:24})
        echo "|$registry|$package|" >> "$provider_dir/README.md"
    done
done
