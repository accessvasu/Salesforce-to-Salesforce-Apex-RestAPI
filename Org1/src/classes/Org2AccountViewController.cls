public with sharing class Org2AccountViewController {
    public String org2AccName 				 {get;set;}
    public String org2AccNumber				 {get;set;}
    public List<ORG2AccountList> accountList {get;set;}
    
    private Integer totalRecs  = 0;
    private Integer OffsetSize = 0;
    private static Integer LimitSize  = Integer.valueOf(restConstants.get('limit').value__c);
    
    // create a list of strings to hold the filters
    List<string> filters = new List<string>();

    public Org2AccountViewController(){
        //accountList  = new List<Account>();
    }
    
    public void searchAcc(){
        totalRecs = 0;
        OffsetSize = 0;
        if(accountList !=null && accountList.size()>0){
            accountList=null;
        }
        searchAccounts();
        filters.clear();
    }
    
    
    public void searchAccounts(){
        
        System.debug('OffsetSize is *'+OffsetSize);
    
        if(accountList != null && !accountList.isEmpty()){
            accountList.clear();
        }
        /*
        String strQuery ='SELECT Id,Name,Active__c, AccountNumber,CreatedDate,Phone,Website,Industry,AnnualRevenue From Account';
        
        if(acc.Name !=null && acc.Name !=''){
            filters.add('Name Like \'%' +acc.Name +'%\' ');
        }
        if(acc.AccountNumber !=null && acc.AccountNumber !=''){
            filters.add('AccountNumber Like \'%' +acc.AccountNumber +'%\' ');
        }
        
        if (filters.size() > 0) {
            strQuery += '  WHERE ' + filters[0];
            for (Integer i = 1; i < filters.size(); i++)
                strQuery += '  AND ' + filters[i];
        }
        if(totalRecs !=null && totalRecs ==0){
            List<Account> accTemp = Database.query(strQuery);
            totalRecs = (accTemp !=null &&accTemp.size()>0)?accTemp.size():0;
        }
        
        system.debug('strQuery ==>'+strQuery );
        // add sort and limits at the end  
        strQuery += ' ORDER BY Name  ASC, CreatedDate DESC LIMIT :LimitSize OFFSET :OffsetSize';
        */
        String urlParam = 'limit='+String.valueOf(LimitSize) + '&offset='+String.valueOf(OffsetSize);
        if(org2AccName !=null && org2AccName !=''){
            filters.add('&accName=' +org2AccName);
        }
        if(org2AccNumber !=null && org2AccNumber !=''){
            filters.add('&accountNumber=' +org2AccNumber);
        }
        if (filters.size() > 0) {
            urlParam += filters[0];
            for (Integer i = 1; i < filters.size(); i++)
                urlParam += filters[i];
        }
        System.debug('url param **'+urlParam);
        accountList  = Org2queryData(urlParam);
        if(accountList !=null &&accountList.size()>0){
            totalRecs = accountList.size();
        }else{
            totalRecs = 0;
            getNxt();getPrev();
        }
        
        //filters.clear();
        //return accountList.size();
    }
    
    public void FirstPage()
    {
        OffsetSize = 0;
        searchAccounts();
    }
    public void previous()
    {
        OffsetSize = (OffsetSize-LimitSize);
        searchAccounts();
    }
    public void next()
    {
        OffsetSize = OffsetSize + LimitSize;
        searchAccounts();
    }
    public void LastPage()
    {
        OffsetSize = totalrecs - math.mod(totalRecs,LimitSize);
        searchAccounts();
    }
    public boolean getPrev()
    {
        System.debug('prev ****'+(OffsetSize==0));
        return (OffsetSize == 0);
    }
    public boolean getNxt()
    {
        if(LimitSize > totalRecs){
            return true;
        }else{
	        return !((OffsetSize + LimitSize) >= totalRecs);
        }
    }
    public static Boolean IsNullorEmpty(String str){
        return str==null || String.isBlank(str);
    }
    private List<ORG2AccountList> Org2queryData(String queryParam){
        List<ORG2AccountList> accList = (List<ORG2AccountList>)invokeService(restConstants.get(ORG2GETACCS).value__c,
                                                             'GET',
                                                             '',
                                                             queryParam);
        return new List<ORG2AccountList>(accList);
    }
    
    private static ServiceOutput oauthLogin(String loginUri, 
                                            String clientIdStr,
                                            String clientSecretStr, 
                                            String username, 
                                            String password) {
        HttpRequest req = new HttpRequest(); 
        
        req.setMethod('POST');
        //req.setEndpoint(loginUri);
        req.setHeader(CONTENT_TYPE, APP_XML_FORM);
        
		/*
            Map<String, String> bodyStr = new Map<String, String>();
            bodyStr.put('grant_type', 'password');
            bodyStr.put(CLIENT_ID, clientIdStr);
            bodyStr.put(CLIENT_SECRET, clientSecretStr);
            bodyStr.put(USER_NAME, EncodingUtil.urlEncode(username, 'UTF-8'));
            bodyStr.put(PASSWORD_SEC_TOKEN, EncodingUtil.urlEncode(password, 'UTF-8'));
		*/
                                                
        String queryParam = '?'+'grant_type=password' +
                    '&'+CLIENT_ID+'=' + clientIdStr +
                    '&'+CLIENT_SECRET+'=' + clientSecretStr +
                    '&'+USER_NAME+'=' + EncodingUtil.urlEncode(username, 'UTF-8') +
                    '&'+PASSWORD_SEC_TOKEN+'=' + EncodingUtil.urlEncode(password, 'UTF-8');
      	
        req.setEndpoint(loginUri+queryParam);
        //req.setBody(String.valueOf(JSON.serialize(bodyStr)));
                                                
		Http http = new Http();
        HTTPResponse res;
                                                
        try{
            res = http.send(req);
        }catch(System.CalloutException e){
        }
        System.debug('TOKEN RESPONSE BODY *** '+res.getBody());
                                                
        return new ServiceOutput(res.getStatusCode(),res.getStatus(), res.getBody());
    }
    public static List<Object> invokeService(String serviceName, 
                                            String httpMethod, 
                                            String requestString,
                                            String queryParam){

        String accessToken = (String)tokenGenerator.get('access_token'),
               instanceUrl = (String)tokenGenerator.get('instance_url');

        Http h          = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res ;
        String message, errMessage;

        //set headers 
        req.setHeader(AUTHORIZATION, 'Bearer '+accessToken);        
        req.setHeader(CONTENT_TYPE, APP_JSON); 
    
        //set request obj - params, body and endpoint
        req.setEndpoint(instanceUrl+serviceName+'?'+queryParam);
        req.setMethod(httpMethod);
    
        if(!IsNullOrEmpty(requestString))
            req.setBody(requestString);
        
    	System.debug('service req obj **'+req);
        System.debug('service req auth **'+req.getHeader(AUTHORIZATION));
        Boolean exc = false;
        DateTime T1 = System.now();
        
        try{
            res = h.send(req);
			System.debug('after callout response ***'+res.getBody());
            if(res.getStatusCode() == 200)
                message = res.getBody();
        }catch(Exception e){
            exc = true;
            errMessage = e.getMessage();
            System.debug('errMessage ***'+errMessage);
            //logException();
        }

        // If the request is successful, parse the JSON response.
        if( message != null || !String.isBlank(message) ) {
            Map<String, Object> resultsMap = new Map<String, Object>();
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(message);
            // Cast the values in the 'accList' key as a list
            if(bodyMap != null)
                resultsMap = (Map<String, Object>)bodyMap.get('data');
            if(resultsMap != null){
                System.debug('Received the following accs:');
                List<ORG2AccountList> accList = new List<ORG2AccountList>();
                for (Object obj : (List<Object>)resultsMap.get('output')) {
                    Map<String, Object> accObj = (Map<String, Object>)obj;
                    System.debug('acc obj *** '+obj);
                    
                    accList.add(new ORG2AccountList((String)accObj.get('isActive'), 
                                                    (String)accObj.get('accNumber'), 
                                                    (String)accObj.get('accName'), 
                                                    (String)accObj.get('accId')));
                }  
                System.debug('output **'+accList);
                return accList;
            }
        }
        return null;
    }
    public static Map<String, RestAppUtils__c> restConstants{
        get{
            if(restConstants == null)
                restConstants = RestAppUtils__c.getAll();
            return restConstants;
        } set;
    }
    public static Map<String, Object> tokenGenerator{
        get{
            if(tokenGenerator == null){
                ServiceOutput so = oauthLogin((String)restConstants.get(ORG2AUTH_URL).value__c, 
                                            (String)restConstants.get(CLIENT_ID).value__c,
                                            (String)restConstants.get(CLIENT_SECRET).value__c,
                                            (String)restConstants.get(USER_NAME).value__c, 
                                            (String)restConstants.get(PASSWORD_SEC_TOKEN).value__c);
                
                tokenGenerator  = (Map<String, Object>)JSON.deserializeUntyped(so.responseBody);
            }
            return tokenGenerator;
        } set;
    }
    
    public enum HTTP_METHOD {GET,POST,PUT}

    public static final String AUTHORIZATION      = 'Authorization';
    public static final String CONTENT_TYPE       = 'Content-Type';
    public static final String APP_JSON           = 'application/json';
    public static final String APP_XML_FORM       = 'application/x-www-form-urlencoded';
    public static final String CLIENT_ID          = 'client_id';
    public static final String CLIENT_SECRET      = 'client_secret';
    public static final String USER_NAME          = 'username';
    public static final String PASSWORD_SEC_TOKEN = 'password';
    public static final String ORG2AUTH_URL       = 'org2oauth_url';
    public static final String ORG2GETACCS        = 'org2getaccounts';
    public static final String LIMIT_VIEW		  = 'limit';
    
    public class ServiceOutput {
        public Integer responseCode {get;set;} // 200 or 400 
        public String responseStatus {get;set;} // Description of status
        public String responseBody {get;set;} // Body content for response
        public ServiceOutput(Integer c, String s, String body){
            this.responseCode = c;
            this.responseStatus = s;
            this.responseBody = body;
        }
    }
   
}