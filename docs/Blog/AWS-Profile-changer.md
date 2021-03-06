# AWS Profile Changer in Bash

![aws-bash](../images/bash-aws.png)

If you are like me and need to deal with multiple AWS profiles simultaneously, you need to keep switching between profiles. Many plugins are available for bash or zsh, but I want to keep it simple and only run the code that I understand.

You can add the below function to your bashrc to change the `AWS_PROFILE` environment variable on the fly. It will read the AWS config file and list all the available profiles; then, you can select the one you need.


``` bash

function aws_profile() {

    local aws_home="$HOME/.aws"

    local profiles=(`\
        cat ${aws_home}/config | \
        grep profile | \
        sed 's/\[//g;s/\]//g' | \
        cut -d " " -f 2`);

    PS3="Select a profile: [none = 0] "

    select profile in ${profiles[@]}
    do
        selected=$profile;
        break;
    done

    unset $PS3;
    if [ ! -z "${profile}" ];
    then
        export AWS_PROFILE="${profile}";
        export AWS_REGION=$(cat ${aws_home}/config | sed -n "/${profile}/,/\[/p" | grep region | cut -d '=' -f 2 | sed 's/ //g')
        export AWS_ACCESS_KEY_ID=$(cat ${aws_home}/credentials | sed -n "/${profile}/,/\[/p" | grep aws_access_key_id | cut -d '=' -f 2 | sed 's/ //g')
        export AWS_SECRET_ACCESS_KEY=$(cat ${aws_home}/credentials | sed -n "/${profile}/,/\[/p" | grep aws_secret_access_key | cut -d '=' -f 2 | sed 's/ //g')
    fi

}
```

TODO:

- [x] List AWS Profiles
- [x] Select and update AWS profile
- [x] Add region changer
- [ ] Add ability to add a profile
- [ ] Add ability to remove a profile
