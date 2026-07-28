# segment: terraform
# description: Shows current Terraform workspace inside .tf projects
# elements: terraform
typeset -g POWERLEVEL9K_TERRAFORM_SHOW_ON_COMMAND='terraform|terragrunt|pulumi'
typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
  '*prod*'    PROD
  '*staging*' STAGING
  '*'         DEFAULT
)
typeset -g POWERLEVEL9K_TERRAFORM_DEFAULT_FOREGROUND=135
typeset -g POWERLEVEL9K_TERRAFORM_PROD_FOREGROUND=196
typeset -g POWERLEVEL9K_TERRAFORM_STAGING_FOREGROUND=214
typeset -g POWERLEVEL9K_TERRAFORM_VISUAL_IDENTIFIER_EXPANSION='##ICON##'
