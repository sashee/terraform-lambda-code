## Init

* terraform init
* terraform apply

## Observe

```
terraform output | awk -F' = ' '{print $2}' | xargs -I {} aws lambda invoke --function-name {} >(cat) > /dev/null'
```

## Update

* change the inline code in main.tf
* change the src/main.js
* terraform apply
