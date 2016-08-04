/**
ORG2 API Manager class
*/
@RestResource(urlMapping='/APIManager/*')
global class APIManager {
    public static final String NO_RECORD_FOUND      = '302';
    public static final String SUCCESS              = '200';
    public static final String PARTIAL              = '204';
    public static final String NO_VALID             = '301';
    public static final String LIMIT_SIZE           = 'limit';
    public static final String OFFSET               = 'offset';    
    public static final String GET_ACCOUNTS_SERVICE = 'getAccounts';
    public static final String SUCCESS_STR          = 'Success';
    public static final String LOG_STR              = 'LOG';
    public static final String ERROR_STR            = 'Error';
    public static final String EXCEPTION_STR        = 'Exception';
    
    public static RestResponseHandler finalResponse {get;set;}
    public static Account g_accRec{get;set;}
    public static Datetime startTime {get; set;}

    public class APIException extends Exception {}

    public static Map<String, ApiMapping__c> apiPair{
        get{
            if(apiPair == null){
                apiPair = ApiMapping__c.getAll();
            }
            return apiPair;
        }set;
    }

    @HttpGet
    global static RestResponseHandler get() {

        //intialize the request objs
        startTime                       = Datetime.now();
        RestRequest req                 = RestContext.request;
        RestResponse res                = RestContext.response;
        String accId                    = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        Map<String, String> queryParams = RestContext.request.params;
        ResponseDataSet dataRes         = new ResponseDataSet();
        finalResponse                   = new RestResponseHandler();
        
        //declare and find the target obj
        List<Account> accList              = new List<Account>();
        try{
            if(accId.equalsIgnoreCase(GET_ACCOUNTS_SERVICE)){//for the /APIManager/getAccounts service
                
                //extract query param values
                String limitSize = IsNullorEmpty(queryParams.get(LIMIT_SIZE))? '10' : queryParams.get(LIMIT_SIZE);
                String pageIndex = IsNullorEmpty(queryParams.get(OFFSET))? '0' : queryParams.get(OFFSET);
                String accName   = IsNullorEmpty(queryParams.get('accName'))? '' : queryParams.get('accName');
                String accNum    = IsNullorEmpty(queryParams.get('accountNumber'))? '' : queryParams.get('accountNumber');
                
                System.debug('query params **'+queryParams);
                //query the record set with provided pagination
                accList = retrieveRecords(Integer.valueOf(limitSize), 
                                            Integer.valueOf(pageIndex), 
                                            accName, 
                                            accNum);
                  
                if(accList.size() > 0){//SUCCESS response
                    dataRes            = formatGetResponse(accList);
                    finalResponse.code = SUCCESS;
                    finalResponse.msg  = 'Records found!!';
                    finalResponse.data = dataRes;
                }else{ //SUCCCESS request - but bad input
                    finalResponse.code = NO_RECORD_FOUND;
                    finalResponse.msg  = 'input request is not found in system';
                    throw new APIException('bad input request');
                }
                return finalResponse;
            }
            //If service request is NOT getAccounts but with specified account /APIManager/0015000001BvId1
            accList = findAccounts(accId); 
            if(accList.size() == 0){//BAD INPUT 
                finalResponse.code = NO_RECORD_FOUND;
                finalResponse.msg  = 'input request is not found in system';
                throw new APIException('bad input request');
            }else{ //SUCCESS RESPONSE when record found
                dataRes            = formatGetResponse(accList);
                finalResponse.code = SUCCESS;
                finalResponse.msg  = 'Record found!!';
                finalResponse.data = dataRes;
            }
        }catch(APIException e){
            //log the exception thrown in the exception object
            System.debug('Message    : ' + e.getMessage());    
            System.debug('Cause      : ' + e.getCause());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());

            logException(String.valueOf(req), startTime ,'Error Occurred: '+e.getMessage());
        }finally{
            //log the webservice request & response 
            logWebService(String.valueOf(req), String.valueOf(JSON.serialize(finalResponse)), startTime, 'ORG1');
        }

        //return api response
        return finalResponse;
    }
    
    @HttpPost
    global static RestResponseHandler create(){

        //intialize the request obj
        startTime                  = Datetime.now();
        RestRequest req            = RestContext.request;
        String accId               = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1); 
        String reqBody             = req.requestBody.toString();
        Map<String, Object> reqObj = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
        List<Account> accRecs      = new List<Account>();
        finalResponse              = new RestResponseHandler();
        
        try{
            if(!isValidateInput(reqObj)){
                finalResponse.code = NO_VALID;
                finalResponse.msg  = 'Input data is invalid!!';
                throw new APIException('bad input request');
            }else if(checkAccountAvailability(String.valueOf(reqObj.get('name')))){
                accRecs = findAccounts(g_accRec.Id);
                finalResponse.code = PARTIAL;
                finalResponse.msg  = 'Object is already available!!';
                finalResponse.data = formatGetResponse(accRecs);
            }else{
                Account a = setupAccObj(reqObj);
                Account resObj   = persistDataObj(a);
                finalResponse.code = SUCCESS;
                finalResponse.msg  = 'A new Object is created!!';
                finalResponse.data = formatCreateResponse(resObj);
            }
        }catch(APIException e){

            System.debug('Message    : ' + e.getMessage());    
            System.debug('Cause      : ' + e.getCause());    
            System.debug('Line number: ' + e.getLineNumber());    
            System.debug('Stack trace: ' + e.getStackTraceString());

            //log the exception for troubleshooting purposes
            logException(String.valueOf(req), startTime ,'Error Occurred: '+e.getMessage());
        }finally{

            //log the webservice request & response 
            logWebService(String.valueOf(req), String.valueOf(JSON.serialize(finalResponse)), startTime, 'ORG1');
        }

        //response return
        return finalResponse;
    }
    private static void logException(String req, DateTime dt, String errMsg){
        System.debug('Req Error ** '+ req);
        System.debug('Err Msge *** '+errMsg);
        try{
            insert new APILog__c(Request__c = req,
                                 TimeRequested__c = dt,
                                 Type__c = EXCEPTION_STR,
                                 Status__c = ERROR_STR); 
        }catch(DMLException ex){
            System.debug('DML error ***'+ex.getMessage());
        }
    }
    private static void logWebService(String inputData, String respData, DateTime dt, String clientApp){
        try{
            insert new APILog__c(Request__c = inputData,
                                 Response__c = respData,
                                 TimeRequested__c = dt,
                                 Type__c = LOG_STR,
                                 Status__c = SUCCESS_STR, 
                                 ConsumerApplication__c = 'ORG1'); 
        }catch(DMLException ex){
            System.debug('DML error ***'+ex.getMessage());
        }
    }
    private static ResponseDataSet formatGetResponse(List<Account> recs){
        List<Bean> res = new List<Bean>();
        for(Account a: recs)
            res.add(new Bean(a.Id, a.Name, a.AccountNumber, a.Active__c));
        return new ListOfAccounts(res);
    }
    private static ResponseDataSet formatCreateResponse(Account a){
        return new AccountInformation(String.valueOf(a.Id));
    }
    private static Boolean IsNullorEmpty(String str){
        return str==null || String.isBlank(str);
    }

    //method to setup
    private static Boolean isValidateInput(Map<String, Object> reqObj){
        return !IsNullorEmpty(String.valueOf(reqObj.get('name')));
    }

    //method sets up json key-value to object field
    private static Account setupAccObj(Map<String,Object> reqObj){
        Account setupAccObj = new Account();
        for(String key : reqObj.keyset()){
            setupAccObj.put(apiPair.get(key).FieldName__c, reqObj.get(key));
        }
        return setupAccObj;
    }

    //create the record and query the accountNumber column to client
    private static Account persistDataObj(Account accRec){
        Account accObj = new Account();
        try{
            insert accRec;
            accObj = [SELECT 
                           Id, Name, AccountNumber 
                       FROM 
                           Account 
                       WHERE 
                           Id =: accRec.Id
                       LIMIT 
                           1        
                      ][0];
        }catch(DmlException e) {
            // specific exception.
            throw new APIException('input obj could not be inserted.', e);
        }
        return accObj;
    }

    //query and check to find the records availability
    private static Boolean checkAccountAvailability(String accName){

        Boolean isAvailable = FALSE;
        //SOSL string can also be used here to find the records availability
        String soqlStr = 'SELECT Id, Name, AccountNumber, Active__c FROM Account WHERE Name LIKE \'%'+accName+'%\' limit 1';
        System.debug('soql ***'+soqlStr);
        if(g_accRec == null){
            List<Account> aList = Database.query(soqlStr);
            System.debug('acc List 1**'+aList);
            if(aList.size()>0){
                g_accRec = aList[0];
                isAvailable = TRUE;
            }
        }
        System.debug('available **'+isAvailable);
        return isAvailable;
    }

    //query in org2 to find pagination set of recs
    private static List<Account> retrieveRecords(Integer LimitSize, Integer OffsetSize, String accName, String accNum){
        String queryStr = 'SELECT Id, Name, AccountNumber, Active__c FROM Account ';
        if(accName != ''){
            queryStr += ' WHERE Name LIKE \'%'+ accName +'%\'';
        }
        if(accName != '' && accNum != ''){
            queryStr += ' AND AccountNumber LIKE \'%'+ accNum +'%\'';
        }else if(accNum != ''){
            queryStr += ' WHERE AccountNumber LIKE \'%'+ accNum +'%\'';
        }
        queryStr +=  ' ORDER BY Name  ASC';
        if(LimitSize > OffsetSize){
            queryStr += ' LIMIT :LimitSize  OFFSET 0';
        }else{
            queryStr += ' LIMIT :LimitSize OFFSET :OffsetSize';
        }
        System.debug('query str ***'+queryStr);
        List<Account> recList = Database.query(queryStr);
        if(recList.size()>0)
            return recList;
        else
            return new List<Account>();
    } 
    
    //query in org2 for the available accounts
    private static List<Account> findAccounts(String accId){
        List<Account> aList = [SELECT 
                                    Id, Name, AccountNumber, Active__c 
                                FROM 
                                    Account 
                                WHERE 
                                    Id =: accId];
        System.debug('acc List 2 **'+aList);
        if(aList.size()>0){
            return aList;
        }else{
            return new List<Account>();
        }
    }

    //all client responses gets this object as json response
    global class RestResponseHandler{
        global String code {get;set;}
        global String msg {get;set;}
        global String objId {get;set;}
        global ResponseDataSet data{get;set;}
        
        global RestResponseHandler(){}
    }

    //virtual class used for extending the response wrapper classes...
    global virtual class ResponseDataSet{

        //client requires any recordCount - child classes can override the method
        protected virtual void recordCount(){}
    }
    
    //wrapper class for GET and CREATE account response
    public class AccountInformation extends ResponseDataSet{
        public String output {get;set;}
        AccountInformation(String r){
            this.output = r;
        }
    }

    //wrapper class for GET ACCOUNT LIST response
    public class ListOfAccounts extends ResponseDataSet {
        public List<Bean> output {get;set;}
        ListOfAccounts(List<Bean> r){
            this.output = r;
        }
    }

    //This is Response BEAN setup
    public class Bean{
        public String accId{get;set;}
        public String accName{get;set;}
        public String accNumber{get;set;}
        public String isActive{get;set;}
        public Bean(String a, String n, String an, String isA){
            this.accId = a;
            this.accName = n;
            this.accNumber = an;
            this.isActive = isA;
        }
    }
}