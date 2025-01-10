#!/bin/bash
find ./clusters -type d -name crossplane-resources -print0 | sort -z | while read -d $'\0' file
do
    provider_dir="$file/providers"
    content=""
    echo "# Crossplane Providers" > "$provider_dir/README.md"
    echo "## Upbound Providers" >> "$provider_dir/README.md"
    echo "| Registry | Name | Version |" >> "$provider_dir/README.md"
    echo "| -------- | ---- | ------- |" >> "$provider_dir/README.md"
    find $provider_dir -type f -name "*.yaml" -not -name "kustomization.yaml"  -print0 | sort -z | while read -d $'\0' file
    do
        result=$(grep -E "xpkg.upbound.io/upbound/(.*)" $file)
        if [ -z "$result" ]; then
            continue
        fi
        result=$(echo $result | xargs)
        result=$(echo ${result:9})
        registry=$(echo ${result:0:23})
        package=$(echo ${result:24})
        IFS=: read -r name version <<< "$package"
        echo "|$registry|$name|$version" >> "$provider_dir/README.md"
    done
    cat "$provider_dir/README.md"
done
