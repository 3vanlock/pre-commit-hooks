#!/bin/bash

generate_cluster_app_doc() {
    echo "$content" > $1
}

files=$(find . -name cluster-app.yaml)

for file in $files; do
    dir="${file%/*}/"
    name=$(yq -r '.application.name' "$file")
    version=$(yq -r '.application.version' "$file")
    helm=$(yq -r '.application.helm.tempalted' "$file")
    if [ "$helm" = "true" ]; then
        helm_template_version=$(yq -r '.application.helm.version' "$file")
    fi
    incident_priority=$(yq -r '.application.incident.priority' "$file")
    incident_description=$(yq -r '.application.incident.description' "$file")
    incident_affected=$(yq -r '.application.incident.affected_users' "$file")

    content=$(cat <<EOT
# $name

## Incident Managmenet
- <strong>Priority</strong>: $incident_priority
- <strong>Affected Users</strong>: $incident_affected
- <strong>Degradation Description</strong>: $incident_description
EOT
)

    if [ ! -f "$dir/CLUSTER-APP.md" ]; then
        echo "No CLUSTER-APP.md file found. Generating..."
        generate_cluster_app_doc "$dir/CLUSTER-APP.md"
        exit 1
    fi

    if [ "x$content" != "x$(cat $dir/CLUSTER-APP.md)" ]; then
        echo "Cluster app documentation does not match. Updating..."
        generate_cluster_app_doc "$dir/CLUSTER-APP.md"
        exit 1
    fi
done

echo "Cluster app docs are up to date"
exit 0