#!/bin/bash
set -e
set -o pipefail

##
# Functions
##
display_section() {
  section=$(echo "$1" | sed 's/^\(.\)/\U\1/')

  echo ""
  echo "##"
  echo "# $section"
  echo "##"
  echo ""
}

##
# Main script
##
while getopts 'a:c:h' opt; do
  case "$opt" in
    a)
      action=$OPTARG
      ;;
    c)
      configuration_file=$OPTARG
      ;;
    ?|h)
      echo "Usage: $(basename $0) [-a action] [-c configuration file]"
      echo ""
      echo "Example: $(basename $0) -a plan -c example-org"
      echo ""
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

if [[ ! $action =~ ^(plan|apply|destroy)$ ]]; then
  echo "[Error] Wrong value for action. Expected: plan, apply or destroy. Got: $action"
  exit 1
fi

cd ./infra

# Format code
display_section "format"
tofu fmt -recursive 

# If .terraform folder exists and contains a terraform.tfstate file
if [[ -f ".terraform/terraform.tfstate" ]]; then
  # Get current configuration file inside .terraform folder
  current_configuration_file=$(jq -r '.backend.config.path' .terraform/terraform.tfstate | cut -d'/' -f2 | cut -d'.' -f1)
  if [[ $configuration_file != $current_configuration_file ]]; then
    rm -rf .terraform
  fi
fi

# Init
display_section "init"
tofu init -backend-config=path=tfstates/${configuration_file}.tfstate

# Validate
display_section "validate"
tofu validate -var-file=configurations/${configuration_file}.tfvars

# Plan or apply
display_section $action
tofu ${action} -var-file=configurations/${configuration_file}.tfvars
