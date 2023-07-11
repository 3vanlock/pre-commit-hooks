#!/bin/bash

content=$(cat <<EOT
# Policies


| Name | Subject | Description | Severity | Action | Background |
| ---- | ------- | ----------- | -------- | ------ | ---------- |
EOT
)

generate_policy_doc() {
    echo "$content" > $1
}

files=$(git diff --cached --name-only --diff-filter=ACM)

for file in $files; do
    extension="${file##*.}"
    if [[ "$extension" =~ ^(yaml|yml)$ ]]; then
        kind=$(yq eval '.kind' $file)
        if [[ "$kind" =~ ^(Policy|ClusterPolicy)$ ]]; then
            dir="${file%/*}/"
            echo $file

            name=$(yq eval '.metadata.name' $file)
            subject=$(yq eval '.metadata.annotations."policies.kyverno.io/subject"' $file)
            description=$(yq eval '.metadata.annotations."policies.kyverno.io/description"' $file)
            severity=$(yq eval '.metadata.annotations."policies.kyverno.io/severity"' $file)
            action=$(yq eval '.spec.validationFailureAction' $file)
            background=$(yq eval '.spec.background' $file)

            content=$(cat <<EOT
$content
|$name|$subject|$description|$severity|$action|$background|"
EOT
)
        fi
    fi
done

if [ ! -f "./POLICIES.md" ]; then
    echo "No POLICIES.md file found. Generating..."
    echo "$content" > POLICIES.md
    exit 1
fi

if [ "x$content" != "x$(cat ./POLICIES.md)" ]; then
    echo "Policy documentation does not match. Updating..."
    echo "$content" > POLICIES.md
    exit 1
fi

echo "Policy docs are up to date"
exit 0
