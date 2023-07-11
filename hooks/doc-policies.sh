#!/bin/bash

# Only create documentation for Policy, ClusterPolicy found in ''./cluster-apps/kyverno/policies'
if [ ! -d "./cluster-apps/kyverno/policies/" ]; then
    echo "No Kyverno policies in standard directory."
    exit 0
fi

# Accumulate file list and sort for standard table order
files=$(find ./cluster-apps/kyverno/policies/ -regextype egrep -regex '.*ya?ml$' | sort)

# Policy documentation header
content=$(cat <<EOT
# Policies


| Name | Category | Subject | Description | Severity | Action | Background |
| ---- | -------- | ------- | ----------- | -------- | ------ | ---------- |
EOT
)

for file in $files; do
    kind=$(yq eval '.kind' $file)
    # Verify Kind is Policy or ClusterPolicy
    if [[ "$kind" =~ ^(Policy|ClusterPolicy)$ ]]; then
        name=$(yq eval '.metadata.name' $file)
        category=$(yq eval '.metadata.annotations."policies.kyverno.io/category"' $file)
        subject=$(yq eval '.metadata.annotations."policies.kyverno.io/subject"' $file)
        description=$(yq eval '.metadata.annotations."policies.kyverno.io/description"' $file)
        severity=$(yq eval '.metadata.annotations."policies.kyverno.io/severity"' $file)
        action=$(yq eval '.spec.validationFailureAction' $file)
        background=$(yq eval '.spec.background' $file)

        # Append Policy attributes to documentation table
        content=$(cat <<EOT
$content
|$name|$category|$subject|$description|$severity|$action|$background|"
EOT
)
    fi
done

# If POLICIES document doesn't exist, create it
if [ ! -f "./cluster-apps/kyverno/POLICIES.md" ]; then
    echo "No POLICIES.md file found. Generating..."
    echo "$content" > ./cluster-apps/kyverno/POLICIES.md
    exit 1
fi

# If POLICIES content is not up to date, generate it
if [ "x$content" != "x$(cat ./cluster-apps/kyverno/POLICIES.md)" ]; then
    echo "Policy documentation does not match. Updating..."
    echo "$content" > ./cluster-apps/kyverno/POLICIES.md
    exit 1
fi

echo "Policy docs are up to date"
exit 0
