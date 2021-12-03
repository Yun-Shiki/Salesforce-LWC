public class diasVaca {

    public static void CalcuDV(List <String> idsEmp){
        List<Resource__c> emp = [select Vacaciones_pendientes__c,Vacaciones_totales__c,
                                 (select Inicio_de_vacaciones__c , Final_de_vacaciones__c, Tipo_de_vacaciones__c from Vacaciones1__r where Estado__c ='Aceptadas')
                                 from Resource__c where id =:idsEmp];
        List<Resource__c> empUp = new List<Resource__c>();
        List<Allocation__c> festivos = [select Start_Date__c,End_Date__c,Resource__c from Allocation__c where Project__r.Name = 'Festivos'];
        HTCalculo calculoDF = new HTCalculo();

        //DiasV la diferencia de las fechas sin fines de semana
        Integer diasV = 0;
        //Dias dias de vacaciones en total al año
        Integer dias ;
        Date year = date.today();
        for(Resource__c e:emp){
            //Asigna el todal de vacaciones que tiene al año a dias
            dias = (Integer)e.Vacaciones_totales__c;
           
            for(Vacaciones__c v:e.Vacaciones1__r){
                
                //Si el tipo es ordinario y que dias es mayor que el queda y el año de vacaciones es de este año
                if(v.Tipo_de_vacaciones__c == 'Ordinarias' && dias >= diasV &&
                   year.year() == v.Final_de_vacaciones__c.year() && year.year() == v.Inicio_de_vacaciones__c.year()) {     
                  diasV = DiasWeekend.getWorkingDays(v.Inicio_de_vacaciones__c,v.Final_de_vacaciones__c);
                       for(Allocation__c f:festivos){
                           if(e.Id == f.Resource__c){
                               diasV -= calculoDF.SihayVaca(v.Inicio_de_vacaciones__c,v.Final_de_vacaciones__c,f.Start_Date__c,f.End_Date__c);
                           }
                       }
                    dias -= diasV;
                }
     
            } 
            //Asigna dias restantes al objeto
                e.Vacaciones_pendientes__c = dias;
                empUp.add(e);
        }
        
        update empUp;
    }

}