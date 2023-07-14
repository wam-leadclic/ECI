/********************************************************************************** 
* @author       Javier Suárez Jiménez
* @date         23/04/2020
* @description  The bulkified CTI Client interface with all methods
* @Revision
**********************************************************************************/
public interface CESS_BulkifiedCTIClient {

   //-- SERVICE METHODS
   CESS_BulkifiedCTIResponseDto.InsertCampaingCalls insertCampaingCalls(CESS_BulkifiedCTIRequestDto.InsertCampaingCalls payload);
   CESS_BulkifiedCTIResponseDto.InsertScheduleCalls insertScheduleCalls(CESS_BulkifiedCTIRequestDto.InsertScheduleCalls payload);
   CESS_BulkifiedCTIResponseDto.DeleteCalls deleteCalls(CESS_BulkifiedCTIRequestDto.DeleteCalls payload);
    CESS_BulkifiedCTIResponseDto.DeleteCalls deleteLeadInCTI(CESS_BulkifiedCTIRequestDto.DeleteCalls payload);
   CESS_BulkifiedCTIResponseDto.UpdateCalls updateCalls(CESS_BulkifiedCTIRequestDto.UpdateCalls payload);

}