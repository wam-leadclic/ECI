/**********************************************************************************
* @author       Francisco José Pérez
* @date         25/06/2020
* @description  Trigger helper class fot the Task entity.
* @Revision

FECHA       AUTOR    DESCRIPCION<br/>
24/09/2021  LCS SCA  Modificación. Se añade mecanismo de control en validateCreateLlamadasPlanificadas para que no se puedan duplicar llamadas planificadas.
16/01/2022  LCS SER  Modificación. Se juntan las 3 llamadas a futuro en una sola para que la API de INETUM pueda procesarlas
27/04/2022  LCS JLQ  Modificación. Eliminar funcionalidad de las tareas de tipo ‘Technical’
02/08/2022  LCS MKB  Modificación. Se añade la planificación de las tareas con contacto
02/08/2022  LCS JCL  Revisión.
05/08/2022  LCS JCL  Revisión test.
13/07/2023  LCS JCB  Se añade método updateRelatedTasksNotFuture, para evitar errores en ejecuciones desde Batch o métodos que ya son futuros.
**********************************************************************************/
public with sharing class CESS_TaskTriggerHelper {

    @testVisible
    private static final String TASK_TYPE = 'Schedule Call';
    @testVisible
    private static final String TASK_STATUS_NOT_STARTED = 'Not Started';
    @testVisible
    private static final String TASK_STATUS_COMPLETED = 'Completed';
    private static final Set<String> TASK_COMPLETE_CANCELLED = new Set<String> { TASK_STATUS_COMPLETED, 'Cancelled' };
    @testVisible
    private static final String CUSTOMER_STATUS_INACTIVE = 'INACTIVE';
    @testVisible
    private static final String CALL_ALREADY_SCHEDULED = 'Ya se ha planificado esta llamada.';
    @testVisible
    private static final String NO_NEW_CALLS = 'No se pueden crear nuevas llamadas en';
    @testVisible
    private static final String NO_DELETE_SCHEDULED_CALLS = 'No se pueden borrar llamadas planificadas.';
    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';

    private static final String ACTION_INSERT = 'insert';
    private static final String ACTION_UPDATE = 'update';
    private static final String ACTION_DELETE = 'delete';

    public static  String action = null;

    public static void checkNewAndUpdateTasks( List<Task> newList, Map<Id, String> controlCTIMap, Map<Id, Opportunity> opportunityMap, Map<Id, Lead> leadMap,
                                               Map<Id, Lead> maxIntentosleadMap, Map<Id, Contact> contactMap ) {

        List<String> opptysIds = new List<String>();
        List<String> leadsIds = new List<String>();
        List<String> contactsIds = new List<String>();
        List<Group> lCessTaskGroup = [ SELECT Id, DeveloperName, Type, Name FROM Group WHERE DeveloperName = 'Cess_Tasks' AND Type = 'Queue' ];
        for( Sobject to : newList ) {

            Task t = (Task) to;
            if( t.Type == TASK_TYPE ) {

                String whatId = (String) t.WhatId; //This variable is needed for the startwith method
                String whoId = (String) t.whoId; //This variable is needed for the startwith method
                if( ( lCessTaskGroup.size() > 0 ) && ( whoId != null && whoId.startsWith( '00Q' ) ) ) {
                    t.OwnerId = lCessTaskGroup[0].Id;
                }

                // Si el whatid es una oportunidad (también podría ser una campaña de cti)
                if( whatId != null && whatId.startsWith( '006' ) ) {
                    opptysIds.add( whatId );
                // Si el whoid es un lead
                } else if( whoId != null && whoId.startsWith( '00Q' ) ) {
                    leadsIds.add( whoId );
                // Si el whoid es un contacto
                } else if( whoId != null && whoId.startsWith( '003' ) ) {
                    contactsIds.add( whoId );
                }

            }

        }

        // JCL - Revisar si no tienen que ser 3 ifs independientes
        if( opptysIds.size() > 0 ) {
            opportunityMap.putAll( [ SELECT IsClosed, StageName FROM Opportunity WHERE Id IN :opptysIds ] );
        } else if( leadsIds.size() > 0 ) {
            leadMap.putAll( [ SELECT Status, Contact_Attempts__c FROM Lead WHERE Id IN :leadsIds ] );
        } else if( contactsIds.size() > 0 ) {
            contactMap.putAll( [ SELECT Customer_Status__c FROM Contact WHERE Id IN :contactsIds ] );
        }

    }

    public static void setReminderAndPlanificada( Task t ) {

        if( t.Type == TASK_TYPE ) {
            t.ReminderDateTime = t.CESS_Fecha_Planificada__c;
        }

    }

    public static void validateCreateLlamadasPlanificadas( Task t, Map<Id, Opportunity> opportunityMap, Map<Id, Lead> leadMap, Map<Id, Contact> contactMap ) {

        if( t.Type == TASK_TYPE ) {

            Opportunity o = opportunityMap.get( t.WhatId );
            if( o != null ) {

                Integer sameTaskOpp = [ SELECT COUNT() FROM Task WHERE WhatId = :t.WhatId AND Type = :TASK_TYPE
                                                                       AND CESS_Fecha_Planificada__c = :t.CESS_Fecha_Planificada__c ];

                if( sameTaskOpp != 0 ) {
                    t.addError( CALL_ALREADY_SCHEDULED );
                }
                if( o.IsClosed ) {
                    t.addError( NO_NEW_CALLS + ' oportunidades cerradas.' );
                }

            } else {

                Lead l = leadMap.get( t.WhoId );
                Contact c = contactMap.get( t.WhoId );
                if( l != null ) {

                    Integer sameTaskLead = [ SELECT COUNT() FROM Task WHERE WhoId = :t.WhoId AND Type = :TASK_TYPE
                                                                            AND CESS_Fecha_Planificada__c = :t.CESS_Fecha_Planificada__c ];

                    if( sameTaskLead != 0 ) {
                        t.addError( CALL_ALREADY_SCHEDULED );
                    }
                    if ( l.Status == LEAD_STATUS_UNQUALIFIED ) {
                        t.addError( NO_NEW_CALLS + ' leads cerrados.');
                    }

                } else if( c != null ) {

                    Integer sameTaskContact = [ SELECT COUNT() FROM task WHERE WhoId = :t.WhoId AND Type = :TASK_TYPE
                                                                               AND CESS_Fecha_Planificada__c = :t.CESS_Fecha_Planificada__c ];

                    if( sameTaskContact != 0 ) {
                        t.addError( CALL_ALREADY_SCHEDULED );
                    }
                    if ( c.Customer_Status__c == CUSTOMER_STATUS_INACTIVE ) {
                        t.addError( NO_NEW_CALLS + ' contactos inactivos.');
                    }

                }

            }

        }

    }


    public static void controlUpdatePlanificadas( Task t, Task tNew, Map<Id, Opportunity> opportunityMap, List<Task> totalTasksToUpdate, List<Id> totalTasksIdsToDelete,
                                                  List<Id> totalTasksIdsToUpdate, Map<Id, Lead> leadMap, Boolean hasInsert, Map<Id, Contact> contactMap ) {

        if( tNew.Type == TASK_TYPE ) {

            Opportunity o = opportunityMap.get( t.WhatId );

            // The task come from an opportunity
            if( o != null ) {

                if( t.cti_error__c != tNew.cti_error__c ) {
                    totalTasksToUpdate.add( tNew );
                }
                if( t.Status != TASK_STATUS_COMPLETED && o.IsClosed ) {
                    totalTasksIdsToDelete.add( t.Id );
                } else if( !o.IsClosed && !hasInsert && !TASK_COMPLETE_CANCELLED.contains( tNew.Status ) && t.CESS_Fecha_Planificada__c != tNew.CESS_Fecha_Planificada__c ) {
                    totalTasksIdsToUpdate.add( t.Id );
                } else if( !o.IsClosed && !hasInsert && TASK_COMPLETE_CANCELLED.contains( tNew.Status ) ) {
                    totalTasksIdsToDelete.add( t.Id );
                }

            // The task come from a Lead or Contact
            } else {

                Lead l = leadMap.get( t.WhoId );
                Contact c = contactMap.get( t.WhoId );

                // The task come from a lead
                if( l != null ) {

                    if( t.cti_error__c != tNew.cti_error__c ) {
                        totalTasksToUpdate.add( tNew );
                    }
                    if( t.Status != TASK_STATUS_COMPLETED && l.Status == LEAD_STATUS_UNQUALIFIED ) {
                        totalTasksIdsToDelete.add( t.Id );
                    } else if( l.Status != LEAD_STATUS_UNQUALIFIED && !hasInsert && !TASK_COMPLETE_CANCELLED.contains( tNew.Status )
                            && t.CESS_Fecha_Planificada__c != tNew.CESS_Fecha_Planificada__c ) {
                        totalTasksIdsToUpdate.add( t.Id );
                    } else if( l.Status != LEAD_STATUS_UNQUALIFIED && !hasInsert && TASK_COMPLETE_CANCELLED.contains( tNew.Status ) ) {
                        totalTasksIdsToDelete.add( t.Id );
                    }

                // The task come from a Contact
                } else if( c != null ) {

                    if( t.cti_error__c != tNew.cti_error__c ) {
                        totalTasksToUpdate.add( tNew );
                    }
                    if( t.Status != TASK_STATUS_COMPLETED && c.Customer_Status__c == CUSTOMER_STATUS_INACTIVE ) {
                        totalTasksIdsToDelete.add( t.Id );
                    } else if( c.Customer_Status__c != CUSTOMER_STATUS_INACTIVE && !hasInsert && !TASK_COMPLETE_CANCELLED.contains( tNew.Status )
                            && t.CESS_Fecha_Planificada__c != tNew.CESS_Fecha_Planificada__c ) {
                        totalTasksIdsToUpdate.add( t.Id );
                    } else if( c.Customer_Status__c != CUSTOMER_STATUS_INACTIVE && !hasInsert && TASK_COMPLETE_CANCELLED.contains( tNew.Status ) ) {
                        totalTasksIdsToDelete.add( t.Id );
                    }
                }

            }

        }

    }

    public static void controlBorradoPlanificada( SObject so ) {

        Task t = (Task) so;
        if( t.Type == TASK_TYPE ) {
            so.addError( NO_DELETE_SCHEDULED_CALLS );
        }

    }

    public static void insertaMapPlanificada( SObject so, List<Id> totalTasksIdsToInsert ) {

        Task t = (Task) so;
        if ( t.Type == TASK_TYPE && t.Status == TASK_STATUS_NOT_STARTED ) {
            totalTasksIdsToInsert.add( t.Id );
        }

    }


    public static Boolean sincronizaPlanificadas( List<Id> totalTasksIdsToDelete, List<Task> totalTasksToUpdate, List<Id> totalTasksIdsToInsert,
                                                  List<Id> totalTasksIdsToUpdate, Map<Id, Lead> maxIntentosleadMap, Map<Id, String> controlCTIMap, Boolean hasInsert ) {

        if( totalTasksIdsToUpdate.size() > 0 && Trigger.isUpdate && Trigger.isBefore ) {

            hasInsert = true;
            action = ACTION_UPDATE;
            if( totalTasksToUpdate.size() == 0 ){
                if( System.isBatch() || System.isFuture() ){
                    updateRelatedTasksNotFuture( totalTasksIdsToUpdate, action);
                }else{
                    updateRelatedTasks( totalTasksIdsToUpdate, action);
                }
                
            }

        } else if( totalTasksIdsToInsert.size() > 0  && Trigger.isInsert && Trigger.isAfter ) {

            hasInsert = true;
            action = ACTION_INSERT;
            if( System.isBatch() || System.isFuture() ){
                updateRelatedTasksNotFuture( totalTasksIdsToInsert, action );
            }else{
                updateRelatedTasks( totalTasksIdsToInsert, action );
            }
            

        } else if( totalTasksIdsToDelete.size() > 0 && Trigger.isUpdate && Trigger.isBefore ) {

            action = ACTION_DELETE;
            if( totalTasksToUpdate.size() == 0 ){
                if( System.isBatch() || System.isFuture() ){
                    updateRelatedTasksNotFuture( totalTasksIdsToDelete, action );
                }else{
                    updateRelatedTasks( totalTasksIdsToDelete, action );
                }
                
            }

        }

        return hasInsert;

    }

    @Future(callout = true)
    private static void updateRelatedTasks( List<Id> tasksIds, String action ) {

        if( action == ACTION_UPDATE ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.updateRelatedCalls( tasksIds );

        } else if( action == ACTION_DELETE ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.deleteRelatedCalls( tasksIds );

        } else if( action == ACTION_INSERT ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.insertRelatedCalls( tasksIds );

        }

    }

    private static void updateRelatedTasksNotFuture( List<Id> tasksIds, String action ) {

        if( action == ACTION_UPDATE ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.updateRelatedCalls( tasksIds );

        } else if( action == ACTION_DELETE ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.deleteRelatedCalls( tasksIds );

        } else if( action == ACTION_INSERT ) {

            CESS_BulkifiedCTILogic bctil = new CESS_BulkifiedCTILogic();
            bctil.insertRelatedCalls( tasksIds );

        }

    }

}