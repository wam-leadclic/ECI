/********************************************************************************** 
* @author       LCS - JCB
* @date         24/05/2022
* @description  Mock class for CESS_BulkifiedCTIRestClient for insertCallsFromIntegrationEvents
* @Revision
**********************************************************************************/
@IsTest
global class CESS_BulkifiedCTIRestClientEvent_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
                
        if ( req.getEndpoint().startsWith('callout:WSO2_') ) {
            ORG_WSO2RestClientTest.WSO2HttpResponseGenerator authMock = new ORG_WSO2RestClientTest.WSO2HttpResponseGenerator();
            return authMock.respond(req);
        }
        
        
        List<String> listRes = new List<String>();
        for(Lead l : [SELECT Id FROM Lead  WHERE document_number__c = '15213308G'] ){
            listRes.add('OK EXTERNAL_ID '+l.Id+' SUCCESS SENT');
        }
        
        CESS_BulkifiedCTIResponseDto.InsertCampaingCalls oResponse = new CESS_BulkifiedCTIResponseDto.InsertCampaingCalls();
        
        CESS_BulkifiedCTIResponseDto.Response r = new CESS_BulkifiedCTIResponseDto.Response();
        r.details = 'test';
        r.request_id = 'test';
        r.message = 'test';
        r.total = 'test';
        r.total_ok = 'test';
        r.total_error = 'test';
        r.results = listRes;
        oResponse.response = r;
           
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(oResponse.serialize(false));
        res.setStatusCode(200);
        
        System.debug('1');
        
        return res;        
    }
    
}