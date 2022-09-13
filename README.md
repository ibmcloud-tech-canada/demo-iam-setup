# account-iam

This terrafom sets up standardized access groups for a new account.

It is an example only.  For your use case, you should determine the access groups needed for your account and what policies each access group should be assigned. 

## Template Resources

Standardized Access Groups based on the roles describled for Financial Services [here](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-account-access-management)
  

## How to Run

Run from command line or schematics or tile.

## Input Variables
 

### General

| Name | Description | Type | Default/Example | Required |
| ---- | ----------- | ---- | ------- | -------- |
| ibmcloud_api_key | API Key used to provision resources.  Your key must be authorized to perform the actions in this script. | string | N/A | yes |



