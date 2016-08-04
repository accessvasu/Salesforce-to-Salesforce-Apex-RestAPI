@isTest
global class ORG2CalloutMock implements HttpCalloutMock {
    
    global ORG2CalloutMock(){
        
    }
    global HttpResponse respond(HttpRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('oauth2/token')){
            res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            res.setBody('{'+
						  '"access_token": "REfHM5w96dNHipYfU6sfDBmNGZ3eAhOb7HmqtniZBCir2sg2J0",'+
						  '"instance_url": "https://na3.salesforce.com",'+
						  '"id": "https://login.salesforce.com/id/00D50000000J6QhEAK/00550000001JAtJAAW",'+
						  '"token_type": "Bearer",'+
						  '"issued_at": "1470205208819",'+
						  '"signature": "dMPU8Ha/XIjP4hVefVYN5tJHv0Sku20jUdZnxrEt+U0="'+
						  '}');
            res.setStatusCode(200);
            return res; 
    	}
    	if(req.getEndpoint().contains('getAccounts')){
    		res.setHeader('Content-Type', 'application/json');
            res.setBody('{"objId":null,'+
                         '"msg":"Records found!!",'+
                         '"data":{"output":[{"isActive":"Yes",'+
                                            '"accNumber":"Test-Org2",'+
                                            '"accName":"Test Acc Name 1",'+
                                            '"accId":"0015000001BvIcyAAF"}]},'+
                         '"code":"200"}');
            res.setStatusCode(200);
            return res;
    	}
        return null;
    }
}