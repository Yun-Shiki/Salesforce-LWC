public with sharing class ControladorListproyecto {
   @AuraEnabled(cacheable=true)
    public static List<Project__c> projectList(ID userId){
        List<User> Name =[Select Name from user where id =: userId];
        String nombre = Name[0].Name;
        Id recordID =[Select id from Resource__c where Name =: nombre][0].id;
        List<Project__c> pr = [Select Id,Name,Jefe_de_proyecto__r.Name,Jefe_de_proyecto__r.Email__c,URL_carpeta__c,Descripcion__c,Inicio_del_proyecto__c,Fin_del_proyecto__c,
                               (Select Id, Resource__r.Name,Resource__r.Email__c,Start_Date__c,End_Date__c from Allocations__r where Resource__c =:recordID ) from Project__c where Name !='Vacaciones' and Name != 'Festivos'];
            
        return pr;
    }
    @AuraEnabled(cacheable=true)
    public static List<Project__c> presentP(ID userId){
        system.debug('Usuario' + userId);
        Date hoy = date.today();
        List<Project__c> pr =projectList(userID);
        List<Project__c> presente = new List<Project__c>();
        for(Project__c p:pr){
            for(Allocation__c a: p.Allocations__r){
                if(a.Start_Date__c < hoy && a.End_Date__c > hoy){
                    presente.add(p);
                }
            } 
        }
        System.debug('Presente ' + presente);
        return presente;
    }
    @AuraEnabled(cacheable=true)
    public static List<Project__c> pastP(ID userId){
        Date hoy = date.today();
        List<Project__c> pr =projectList(userID);
        List<Project__c> pasado = new List<Project__c>();
        for(Project__c p:pr){
            for(Allocation__c a: p.Allocations__r){
                if(a.Start_Date__c < hoy && a.End_Date__c < hoy){
                    pasado.add(p);
                }
            } 
        }
        return pasado;
    }
    @AuraEnabled(cacheable=true)
    public static List<Project__c> futurP(ID userId){
        Date hoy = date.today();
        List<Project__c> pr =projectList(userID);
        List<Project__c> futuro = new List<Project__c>();
        if(pr!=null){
        for(Project__c p:pr){
            for(Allocation__c a: p.Allocations__r){
                if(a.Start_Date__c > hoy){
                    futuro.add(p);
                }
            } 
        }  
        return futuro;
        }else {
            return null;
        }
    }   
    
    @AuraEnabled
    public static List<Allocation__c> ListaEmpleados(ID proyecto){

        system.debug(proyecto);

      return [Select Id,Resource__r.Name, Resource__r.Email__c from Allocation__c where Project__c=:proyecto];


       
    }
}