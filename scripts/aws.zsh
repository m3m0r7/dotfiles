ssm() {
  instances=$(aws ec2 describe-tags --filters "Name=resource-type,Values=instance" "Name=key,Values=Name" | \
                 jq -r '.Tags[] | [.ResourceId, .Value] | @csv' | \
                 tr -d '"' | \
                 sed -e 's/\(.*\),\(.*\)/[\1] \2/g')
  instanceId=$(
    echo $instances | \
    fzf | \
    sed -e 's/\[\(.*\)\] .*/\1/g' | \
    awk '{print $1}'
  )

  aws ssm start-session \
    --target $instanceId \
    --document-name AWS-StartInteractiveCommand \
    --parameters command="bash -i"
}
