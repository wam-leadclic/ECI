/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         27/04/2020
* @description  Test class for CESS_BulkifiedCTIRestClient
* @Revision
**********************************************************************************/
@isTest
public class CESS_BulkifiedCTIRestClient_Test {

    @isTest static void insertCampaingCalls1() {
        
        String expectedResult = '{"response":{"total_ok":"test","total_error":"test","total":"test","results":[],"request_id":"test","message":"test","details":"test"}}';
        
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        
        Test.startTest();
        
        CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
        
        CESS_BulkifiedCTIRequestDto.RequestUpsertContact ruc = new CESS_BulkifiedCTIRequestDto.RequestUpsertContact();
        ruc.front_code = 'test';
        ruc.campaign_name = 'test';
        //ruc.columns {get; set;}
        //ruc.values {get; set;}
        ruc.column_filter = 'test';
        
        CESS_BulkifiedCTIRequestDto.InsertCampaingCalls payload = new CESS_BulkifiedCTIRequestDto.InsertCampaingCalls();
        CESS_BulkifiedCTIResponseDto.InsertCampaingCalls res = client.insertCampaingCalls(payload);

        payload.requestInsertContactList.add(ruc);

        // Test serialize methods
        String serializedString = res.serialize(true);

        Test.stopTest();

        System.debug('expectedResult: ' + expectedResult);
        System.debug('serializedString: ' + serializedString);
		// Assertions
        System.assertEquals(expectedResult, serializedString);
    }
    
    @isTest static void insertScheduleCalls1() {
        
        String expectedResult = '{"response":{}}';
        
        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        
        Test.startTest();
        
        CESS_BulkifiedCTIRequestDto.RequestUpsertContact ruc = new CESS_BulkifiedCTIRequestDto.RequestUpsertContact();
        ruc.front_code = 'test';
        ruc.campaign_name = 'test';
        //ruc.columns {get; set;}
        //ruc.values {get; set;}
        ruc.column_filter = 'test';
                                
        CESS_BulkifiedCTIRequestDto.InsertScheduleCalls payload = new CESS_BulkifiedCTIRequestDto.InsertScheduleCalls();
        payload.requestInsertContactList.add(ruc);
               
        CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
        CESS_BulkifiedCTIResponseDto.InsertScheduleCalls res = client.insertScheduleCalls(payload);
        
        // Test serialize methods
        //String serializedString = res.serialize(true); 
        
        Test.stopTest();
        
        // Assertions
        //System.assertEquals(expectedResult, serializedString);
        
    }
    
    @isTest static void deleteCalls1() {
        
        //String expectedResult = '{"response":{}}';
        String expectedResult = '{"response":{"total_ok":"test","total_error":"test","total":"test","results":[],"request_id":"test","message":"test","details":"test"}}';

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        
        Test.startTest();
        
        CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
        CESS_BulkifiedCTIRequestDto.DeleteCalls payload = new CESS_BulkifiedCTIRequestDto.DeleteCalls();
        CESS_BulkifiedCTIResponseDto.DeleteCalls res = client.deleteCalls(payload);
                
        // Test serialize methods
        String serializedString = res.serialize(true);        
        
        Test.stopTest();
        
        System.debug('expectedResult: ' + expectedResult);
        System.debug('serializedString: ' + serializedString);
		// Assertions
        System.assertEquals(expectedResult, serializedString);
    }
    
    @isTest static void updateCalls1() {
        
        //String expectedResult = '{"response":{}}';
        String expectedResult = '{"response":{"total_ok":"test","total_error":"test","total":"test","results":[],"request_id":"test","message":"test","details":"test"}}';

        Test.setMock(HttpCalloutMock.class, new CESS_BulkifiedCTIRestClient_Mock());
        
        Test.startTest();
        
        CESS_BulkifiedCTIRestClient client = new CESS_BulkifiedCTIRestClient();
        CESS_BulkifiedCTIRequestDto.UpdateCalls payload = new CESS_BulkifiedCTIRequestDto.UpdateCalls();
        CESS_BulkifiedCTIResponseDto.UpdateCalls res = client.updateCalls(payload);
                
        // Test serialize methods
        String serializedString = res.serialize(true);        
        
        Test.stopTest();
        
		// Assertions
        System.assertEquals(expectedResult, serializedString);
    }
    
}