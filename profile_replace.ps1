function global:_PWSH_ORIG_PROMPT {
    ""
}
$function:_PSWH_ORIG_PROMPT = $function:prompt
function global:prompt {
  if (Enter-Code) {
    return & $function:_DEVENV_PROMPT
  } else {
    return & $function:_PSWH_ORIG_PROMPT
  }
}