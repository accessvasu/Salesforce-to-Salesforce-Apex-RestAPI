@IsTest
public class APIManagerTest{
    @TestSetup
    static void testDataSetup(){
        //insert records to acc obj
        List<Account> accList = new List<Account>();
        for(Integer i=0;i<20;i++){
            accList.add(new Account(Name = 'Test org2 acc '+ i, 
                                    AccountNumber = 'Test Org2 Acc no '+i,
                                    Active__c = 'Yes'));
        }
        insert accList;

        //insert recs to custom settings
        List<APIMapping__c> jsonObj = new List<APIMapping__c>();
        jsonObj.add(new APIMapping__c(Name = 'name', FieldName__c= 'Name')); 
        jsonObj.add(new APIMapping__c(Name = 'active', FieldName__c= 'Active__c')); 
        jsonObj.add(new APIMapping__c(Name = 'accountNumber', FieldName__c= 'AccountNumber')); 

        insert jsonObj;
    }
    @IsTest
    static void testGetAccounts(){
        // Set up a test request
        RestRequest request = new RestRequest();

        // Set request properties
        request.requestUri =
            '/services/apexrest/APIManager/getAccounts';//?limit=3&offset=0&accName=Test&accNumber=Test';
        request.httpMethod = 'GET';

        // Set other properties, such as parameters
        request.params.put('limit','3');
        request.params.put('offset','0');
        request.params.put('accName','Test');
        request.params.put('accountNumber','Test');
        
        // more awesome code here....
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.get();
        System.assertEquals('200',response.code );
        System.assertEquals('Records found!!',response.msg);

        
    }

    @IsTest
    static void testgetFailRecords(){
        // Set up a test request
        RestRequest request = new RestRequest();

        // Set request properties
        request.requestUri =
            '/services/apexrest/APIManager/getAccounts';
        request.httpMethod = 'GET';

         // Set other properties, such as parameters
        request.params.put('limit','3');
        request.params.put('offset','0');
        request.params.put('accName','Fail');
        request.params.put('accountNumber','Fail');
        
        // more awesome code here....
        // Finally, assign the request to RestContext if used
        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.get();
        System.assertEquals('302',response.code );
        System.assertEquals('input request is not found in system',response.msg);

    }

    @IsTest
    static void testGetOneAccount(){

        Account a = [select id from Account limit 1];

        // Set up a test request
        RestRequest request = new RestRequest();
        // Set request properties for getaccount id
        request.requestUri =
            '/services/apexrest/APIManager/'+a.Id;//?limit=3&offset=0&accName=Test&accNumber=Test';
        request.httpMethod = 'GET';

        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.get();
        System.assertEquals('200',response.code );
        System.assertEquals('Record found!!',response.msg);

    }
    @IsTest
    static void testGetOneFailAccount(){

        // Set up a test request
        RestRequest request = new RestRequest();
        // Set request properties for getaccount id
        request.requestUri =
            '/services/apexrest/APIManager/'+'testfailone';//?limit=3&offset=0&accName=Test&accNumber=Test';
        request.httpMethod = 'GET';

        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.get();
        System.assertEquals('302',response.code );
        System.assertEquals('input request is not found in system',response.msg);

    }
    @IsTest
    static void testCreateAccount(){

        // Set up a test request
        RestRequest request = new RestRequest();
        // Set request properties for getaccount id
        request.requestUri =
            '/services/apexrest/APIManager/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"name":"Hola", "accountNumber":"Warriors 123","active":"Yes"}');

        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.create();
        
        
        System.assertEquals('200',response.code );
        System.assertEquals('A new Object is created!!',response.msg);
        
    }
    @IsTest
    static void testCreateAvailableAccount(){

        // Set up a test request
        RestRequest request = new RestRequest();
        // Set request properties for getaccount id
        request.requestUri =
            '/services/apexrest/APIManager/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"name":"Test", "accountNumber":"Test 123","active":"Yes"}');

        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.create();
        
        
        System.assertEquals('204',response.code );
        System.assertEquals('Object is already available!!',response.msg);
        
    }
    @IsTest
    static void testFailCreateAccount(){

        // Set up a test request
        RestRequest request = new RestRequest();
        // Set request properties for getaccount id
        request.requestUri =
            '/services/apexrest/APIManager/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"name":"", "accountNumber":"Test 123","active":"Yes"}');

        RestContext.request = request;
        
        APIManager.RestResponseHandler response = APIManager.create();
        
        
        System.assertEquals('301',response.code );
        System.assertEquals('Input data is invalid!!',response.msg);
        
    }
}