public class RegularFechaAsignacion {
    
    public static void regularFecha(List <String> idProyecto){
        
        
        List <Project__c> Proyectos=[Select  Inicio_del_proyecto__c, Fin_del_proyecto__c,
                                     (select Start_Date__c, End_Date__c from Allocations__r)  from Project__c where id=:idProyecto ];
        
        List <Allocation__c> Asignaciones= new List<Allocation__c>();
        
        for(Project__c p: Proyectos){ //Recorremos todos los proyectos
            
            for(Allocation__c a:p.Allocations__r){//Recorremos todas las asignaciones de cada proyecto
                
                if( a.Start_Date__c < p.Inicio_del_proyecto__c || a.Start_Date__c > p.Fin_del_proyecto__c ){//Si la fecha de inicio Asignación es antes de la fecha de inicio de proyecto
                    																						// O si la fecha de Inicio de asignacion es después de la fecha de fin de proyecto
                    
                    a.Start_Date__c=p.Inicio_del_proyecto__c; // La fecha de inicio de Asignacion pasará a ser igual a la de Inicio de proyecto              
                              
                }
                if(a.End_Date__c > p.Fin_del_proyecto__c || a.End_Date__c < p.Inicio_del_proyecto__c){ //Si la fecha de final de Asignación es despues de la fecha de fin de proyecto
                    																					// O si la fecha de fin de asignacion es antes de la fecha de inicio de proyecto
                    
                    
                    a.End_Date__c=p.Fin_del_proyecto__c;// La fecha de fin de Asignacion pasará a ser igual a la de fin de proyecto    
                }
                
                 Asignaciones.add(a);//insertamos la asignacion en una lista
            }
        }
        
        Update Asignaciones;//actualizamos los datos de salesforce
     
        
    }

}