global class CESS_replanificaLlamadaCtiSchedulable implements Schedulable{
    global void execute(SchedulableContext sc) {
        Id batchInstanceId = Database.executeBatch(new CESS_replanificaLlamadaCtiBatch());
    }
}