1. Leveraged Terraform as IaC to deploy a lambda function and a cloudwatch event rule to trigger lambda daily.
  Cloudwatch logs was also implemented where Lambda would create its own log group and put log events into it, which helped monitor and fix any errors.
  Followed security and best practices by zipping python file to lambda and only allowing right roles for lambda and cloudwatch to communicate with each other.


This project eliminates the manual need to run a python script

Lambda Automation Cloud Architecture

![image](https://github.com/user-attachments/assets/1c4df5c3-d2e6-4a5f-9b90-84703cb5424d)
