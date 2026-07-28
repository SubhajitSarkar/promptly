# segment: aws
# description: Shows current AWS profile and region
# elements: aws
typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|terraform|pulumi|terragrunt'
typeset -g POWERLEVEL9K_AWS_CLASSES=(
  '*prod*'    PROD
  '*staging*' STAGING
  '*'         DEFAULT
)
typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND=208
typeset -g POWERLEVEL9K_AWS_PROD_FOREGROUND=196
typeset -g POWERLEVEL9K_AWS_STAGING_FOREGROUND=214
typeset -g POWERLEVEL9K_AWS_VISUAL_IDENTIFIER_EXPANSION='##ICON##'
