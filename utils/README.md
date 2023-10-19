## Utils

### Generate temporary credentials to AWS user
```bash
. ./root_get_temporary_token.sh # Will export temporary creds to environment variables
```

```bash
# Testing
aws sts get-caller-identity
```

