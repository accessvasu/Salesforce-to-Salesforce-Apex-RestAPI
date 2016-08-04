public class QueueServiceBroker implements Queueable, Database.AllowsCallouts {
    Map<Id,Account> accObjMap;
    public QueueServiceBroker(Map<Id, Account> accMap){
        this.accObjMap =accMap;
    }
    public void execute(QueueableContext context) {
        for(Account a : accObjMap.values()){
            String serviceName = Org2AccountViewController.restConstants.get(Org2AccountViewController.ORG2GETACCS).value__c;
            String urlParam = 'limit='+accObjMap.size()+'&accName='+EncodingUtil.urlEncode(a.Name, 'UTF-8');
            List<ORG2AccountList> responseWrap = (List<ORG2AccountList>)Org2AccountViewController.invokeService(
															serviceName,
                                                            'GET',
                                                            '',
        													urlParam);
        	if(responseWrap.size()>0){
                handleCalloutResponse(responseWrap[0]);     
            }
        }
        
    }
    public void handleCalloutResponse(ORG2AccountList responseObj){
        String org2AccName = responseObj.accName;
        String org2AccNum  = responseObj.accNumber;
        List<Account> org1Accs = loadOrg1AccsWithOrg2Match(org2AccName);
        
        //update org1 account number with Org2AccountNumber__c
        if(org1Accs.size()>0){
            Account updateOrg1Acc = org1Accs[0];
            updateOrg1Acc.Org2AccountNumber__c = org2AccNum;
            try{
                AccountTriggerHandler2.inFutureContext = true;
                update updateOrg1Acc;
            }catch(Exception e){
                System.debug('update acc err****'+e.getMessage());
            }
        }
        
    }
    private List<Account> loadOrg1AccsWithOrg2Match(String org2AccName){
        return queryAccounts(org2AccName);
    }
    private List<Account> queryAccounts(String accName){
        List<Account> org1Accs = [SELECT Id, Name, AccountNumber 
                                    FROM Account 
                                    WHERE NAME =:accName
                                    LIMIT 1];
        return org1Accs;
    }
}