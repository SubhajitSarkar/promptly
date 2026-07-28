# segment: kubectl
# description: Shows current Kubernetes context and namespace
# elements: kubecontext
typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold'
typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
  '*prod*'    PROD
  '*staging*' STAGING
  '*'         DEFAULT
)
typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND=134
typeset -g POWERLEVEL9K_KUBECONTEXT_PROD_FOREGROUND=196
typeset -g POWERLEVEL9K_KUBECONTEXT_STAGING_FOREGROUND=214
typeset -g POWERLEVEL9K_KUBECONTEXT_VISUAL_IDENTIFIER_EXPANSION='##ICON##'
