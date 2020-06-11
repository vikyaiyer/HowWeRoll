public with sharing class WarehouseSyncSchedule implements Schedulable {
    //  TODO: Schedule runWarehouseEquipmentSync() to run every morning 1am check cronExpression.txt
    public void execute(SchedulableContext ctx) {
        WarehouseCalloutService.runWarehouseEquipmentSync();
    }
}
