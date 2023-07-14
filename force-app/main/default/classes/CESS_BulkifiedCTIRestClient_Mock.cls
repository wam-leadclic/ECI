/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         27/04/2020
* @description  Mock class for CESS_BulkifiedCTIRestClient
* @Revision
**********************************************************************************/
@IsTest
global class CESS_BulkifiedCTIRestClient_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
                
        if ( req.getEndpoint().startsWith('callout:WSO2_') ) {
            ORG_WSO2RestClientTest.WSO2HttpResponseGenerator authMock = new ORG_WSO2RestClientTest.WSO2HttpResponseGenerator();
            return authMock.respond(req);
        }
        CESS_BulkifiedCTIResponseDto.InsertCampaingCalls oResponse = new CESS_BulkifiedCTIResponseDto.InsertCampaingCalls();
        
        CESS_BulkifiedCTIResponseDto.Response r = new CESS_BulkifiedCTIResponseDto.Response();
        r.details = 'test';
        r.request_id = 'test';
        r.message = 'test';
        r.total = 'test';
        r.total_ok = 'test';
        r.total_error = 'test';
        
        oResponse.response = r;
           
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(oResponse.serialize(false));
        res.setStatusCode(200);
        
        System.debug('1');
        
        return res;        
    }
    
}