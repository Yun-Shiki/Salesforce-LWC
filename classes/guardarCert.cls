public class guardarCert {   
    
   @AuraEnabled
    public  static void guardarCertificacion(ID Id, String Tipo, String Certif, String otra){        
		       
        User usuario =[select Email from User where ID=:Id];

        Resource__c emp =[select Id, Email__c from Resource__c where Email__c =: usuario.Email];
        
        Certificaciones__c cert = new Certificaciones__c ( Empleado__c = emp.id, Certificacion_Salesforce__c = Certif,
            Tipo_de_certificacion__c = Tipo, Otra__c = otra);
        
        insert cert;
	}
}