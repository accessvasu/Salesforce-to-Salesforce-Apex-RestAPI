@IsTest
public class AccountTriggerHandlerTest{
    @TestSetup
    static void testDataFacotry(){
        //create custom settings
        List<RestAppUtils__c> custData = new List<RestAppUtils__c>();
             custData.add(new RestAppUtils__c(Name = 'client_id' , Value__c = 'testclientid'));
             custData.add(new RestAppUtils__c(Name = 'client_secret' , Value__c =  'testsecret1'));
             custData.add(new RestAppUtils__c(Name = 'limit' , Value__c =  '4'));
             custData.add(new RestAppUtils__c(Name = 'org2getaccounts' , Value__c =  '/services/apexrest/AdobeAPI/getAccounts'));
             custData.add(new RestAppUtils__c(Name = 'org2oauth_url' , Value__c =  'https://na3.salesforce.com/services/oauth2/token'));
             custData.add(new RestAppUtils__c(Name = 'password' , Value__c =  'WarriorsTest9'));
             custData.add(new RestAppUtils__c(Name = 'username' , Value__c =  'vasu@codesample.com.dev'));

        insert custData;

        List<Account> accRecs = new List<Account>();
        for(Integer i=0;i<100;i++){
            accRecs.add(new Account(Name = 'Test Acc Name '+i,
                                    AccountNumber = 'Test Acc No '+i));
        }
        insert accRecs;
    }
    static testmethod void testCalloutAndQueueable() {
        // query for test data to pass to queueable class
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT id, name, accountnumber
                                                          FROM account
                                                          WHERE name LIKE 'Test Acc Name%']);

        for(Account a : accounts.values()){
            a.Name = 'Test Acc Name 1';
            accounts.clear();
            accounts.put(a.Id, a);
            break;
        }

        // Create our Queueable instance
        QueueServiceBroker testQueue = new QueueServiceBroker(accounts);
        Test.setMock(HttpCalloutMock.class, new ORG2CalloutMock());

        Test.startTest();

        	AccountTriggerHandler2.onAfterUpdate(accounts);
        	AccountTriggerHandler2.onAfterInsert(accounts);

        	System.enqueueJob(testQueue);

        Test.stopTest();

        List<Account> acc = [select id,name, accountnumber,Org2AccountNumber__c  from Account where name = 'Test Acc Name 1' limit 1];
        // runs callout and check results
        System.assertEquals('Test-Org2', acc[0].Org2AccountNumber__c);
    }

    static testmethod void accountTriggerTest(){
        Test.startTest();
        	AccountTriggerHandler2.inFutureContext = false;
            Account a = new Account(Name = 'Test insert');
            insert a;
            a.Name = 'test update';
            update a;
        Test.stopTest();
    }

    static testmethod void accountControllerTest(){

        Test.startTest();
	        Org2AccountViewController av = new Org2AccountViewController();
        	Test.setMock(HttpCalloutMock.class, new ORG2CalloutMock());
        	av.org2AccName = 'Test';
        	av.org2AccNumber = 'Test ';
        	av.searchAcc();
            av.getNxt();
            av.getPrev();
            av.FirstPage();
            av.LastPage();
            av.next();
            av.previous();
        Test.stopTest();

    }

}
