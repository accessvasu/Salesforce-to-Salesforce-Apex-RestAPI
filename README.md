# Salesforce-to-Salesforce-Apex-RestAPI

This is an example of connection one saleforce org(org1) to another salesforce org(org2) using rest apex api.

##### Source Org1 is a consumer. This org contains.
- visualforce page to show the list of accounts from org2 with pagination feature
- oauth2 authentication
- trigger to callout when account is created in org1 and invokes the org2 apis for account check

##### Target Org2 is a provider
- api endpoints are created using rest apex 
- getAccounts to retrieve list of accounts
- create account 


