global class AsignacionEmpleado implements Schedulable {
     global void execute(SchedulableContext SC) {
         List<Resource__c> emp = [select id , (select Status__c from Allocations__r)Asignado__c from Resource__c];
         List<Resource__c> upE = new List<Resource__c>();
         List<Project__c> pro = [Select Fin_del_proyecto__c,Inicio_del_proyecto__c,Active__c	from Project__c ];
         List<project__c> upP = new List<Project__c>();
         List<Allocation__c> allo= new List <Allocation__c>();
         date hoy = date.today();
         //Recorremos todos los empleados
         for(Resource__c e:emp){
             for(Allocation__c a:e.Allocations__r){
                 if(a.Status__c=='Active'){
                     e.Asignado__c=true;
                     if(!upE.contains(e)){
                         upE.add(e);
                     }
                     
                     break;//Si encontramos un empleado con asignacion activo , asignamos como asignado y saltamos al siguiente empleado
                 }    
                 else{
                     e.Asignado__c=false;
                 }
             }
         }
         //Recorremos todos los proyectos
         for(Project__c p:pro){
             if(p.Inicio_del_proyecto__c> hoy || p.Fin_del_proyecto__c < hoy){// si el inicio es mayor que hoy o final es menor que hoy, entra.
                 p.Active__c = false;
                 if(!upP.contains(p)){
                     upP.add(p);
                 }
                 
             }
         }
         if(upE.size()>0){
            Update upE; 
         }
         if(upP.size()>0){
             update upP;
         }
         
     }
}