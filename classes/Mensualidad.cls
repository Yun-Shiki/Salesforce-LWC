public class Mensualidad {
    
    public static void crearMensualidad(List <String> idAsignacion){
        
       List <Allocation__c> Asignacion=[Select Start_Date__c,End_Date__c,Dedication__c, id,
                                         Resource__r.Name,Project__r.Name,Project__r.id, Resource__r.id 
                                         from Allocation__c where id=:idAsignacion and Project__r.Name != 'Vacaciones' and Project__r.Name != 'Festivos' ];   
        
        List <Mensualidad__c> Mensu=new List <Mensualidad__c>();
        for (Allocation__c a: Asignacion){

            Integer MesesEntre = a.Start_Date__c.monthsBetween(a.End_Date__c);
            Date MesSiguiente;
            String nombreMes;
            String mesNumero;
            Decimal Dedicacion;
            
            for(Integer i=0; i<=MesesEntre;i++){
                Date primerMes = date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month(),1);
                Date UltimoMes = date.newInstance(a.End_Date__c.year(),a.End_Date__c.month(),1);
                Date finalMes = date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month()+1,1);
                Date finalMes2= date.newInstance(a.End_Date__c.year(),a.End_Date__c.month()+1,1);
                Dedicacion = a.Dedication__c;
                if (i==0){
                    MesSiguiente=a.Start_Date__c;
                    if(a.Start_Date__c.month() == a.End_Date__c.month() && a.Start_Date__c.year() == a.End_Date__c.year()){
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(a.End_Date__c);
                    }else{
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(finalMes);
                    }  
                 }else if(i == mesesEntre){
                     MesSiguiente=a.End_Date__c;
                     if(a.Start_Date__c.month() == a.End_Date__c.month() && a.Start_Date__c.year() == a.End_Date__c.year()){
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(a.End_Date__c);
                    }else{
                        dedicacion = (a.Dedication__c/(UltimoMes.daysBetween(finalMes2)))*UltimoMes.daysBetween(a.End_Date__c+1);
                    }         
                 }else{
                      MesSiguiente=date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month()+i,1);
                      dedicacion = a.Dedication__c;
                 }
                mesNumero =String.valueOf(MesSiguiente.month());
                if(mesNumero.length() == 1){
                    mesNumero = '0' + mesNumero;
                }
                
             	nombreMes=Fecha.getNombreMes(MesSiguiente.month());
                
                Mensualidad__c mes=new Mensualidad__c(Name= nombreMes + ' ' + MesSiguiente.year(),
                                                      year__c = String.valueOf(MesSiguiente.year()),
                                                      mes__c = mesNumero,
                                                      Dedicacion__c=dedicacion,
                                                      Asignacion__c=a.id,
                                                      Proyecto__c=a.Project__r.id,
                                                      Empleado__c=a.Resource__r.id ,
                                                      FechaAsignacion__c=MesSiguiente
                                                     );
                
                Mensu.add(mes);
            }
        }
        insert Mensu;
    }
    public static void crearNuevoM(List<String> idsAsi){
        List<Allocation__c>  asig = [Select Dedication__c,LastModifiedDate,Start_Date__c,End_Date__c,id,Project__r.id, Project__r.Name, Resource__r.id,Resource__r.Name,
        (select dedicacion__c, FechaAsignacion__c  from Mensualidades__r)
                                     from Allocation__c where id =: idsAsi and Project__r.Name != 'Vacaciones' and Project__r.Name != 'Festivos' ];
        List <Mensualidad__c> Mensu=new List <Mensualidad__c>();
        List<Mensualidad__c> mensuDelete = new List<Mensualidad__c>();
        Integer n;
        String idM; 
        Date MesSiguiente;
        String nombreMes;
        String mesNumero;
        Decimal dedicacion;
        for(Allocation__c a:asig){
            n = a.Start_Date__c.monthsBetween(a.End_Date__c);
            Date primerMes = date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month(),1);
            Date UltimoMes = date.newInstance(a.End_Date__c.year(),a.End_Date__c.month(),1);
            Date finalMes = date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month()+1,1);
            Date finalMes2= date.newInstance(a.End_Date__c.year(),a.End_Date__c.month()+1,1);
            dedicacion = a.Dedication__c;
            for(Integer i=0;i<=n;i++){
                MesSiguiente=date.newInstance(a.LastModifiedDate.Date().year(),a.LastModifiedDate.Date().month()+i,1);
                if (i==0){
                    MesSiguiente=a.Start_Date__c;
                    if(a.Start_Date__c.month() == a.End_Date__c.month() && a.Start_Date__c.year() == a.End_Date__c.year()){
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(a.End_Date__c+1);
                    }else{
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(finalMes);
                    }  
                 }else if(i == n){
                     MesSiguiente=a.End_Date__c;
                     if(a.Start_Date__c.month() == a.End_Date__c.month() && a.Start_Date__c.year() == a.End_Date__c.year()){
                        dedicacion = (a.Dedication__c/(primerMes.daysBetween(finalMes)))*a.Start_Date__c.daysBetween(a.End_Date__c);
                    }else{
                        dedicacion = (a.Dedication__c/(UltimoMes.daysBetween(finalMes2)))*UltimoMes.daysBetween(a.End_Date__c+1);
                    }         
                 }else{
                      MesSiguiente=date.newInstance(a.Start_Date__c.year(),a.Start_Date__c.month()+i,1);
                      dedicacion = a.Dedication__c;
                 }
             	nombreMes=Fecha.getNombreMes(MesSiguiente.month());
                idM = null;
                mesNumero =String.valueOf(MesSiguiente.month());
                if(mesNumero.length() == 1){
                    mesNumero = '0' + mesNumero;
                }
                
             	nombreMes=Fecha.getNombreMes(MesSiguiente.month());
                for(Mensualidad__c m:a.Mensualidades__r){
                    if(m.FechaAsignacion__c.month() == MesSiguiente.month() && m.FechaAsignacion__c.year() == MesSiguiente.year() ){
                        idM = m.Id;
                    }
                    if((m.FechaAsignacion__c.year()> a.End_Date__c.year() || m.FechaAsignacion__c.year()< a.Start_Date__c.year())||(m.FechaAsignacion__c.month() > a.End_Date__c.month() && m.FechaAsignacion__c.year() >= a.End_Date__c.year()) 
                       ||( m.FechaAsignacion__c.month() < a.Start_Date__c.month() && m.FechaAsignacion__c.year() <= a.Start_Date__c.year())){
                        if(!mensuDelete.contains(m)){
                            mensuDelete.add(m);
                        }
                    }
                }
                Mensualidad__c mes = new Mensualidad__c(
                    id = idM,
                    Name= nombreMes + ' ' + MesSiguiente.year(),
                    year__c = String.valueOf(MesSiguiente.year()),
                    mes__c = mesNumero,
                    Dedicacion__c=dedicacion,
                    Asignacion__c=a.id,Proyecto__c=a.Project__r.id,
                    Empleado__c=a.Resource__r.id ,
                    FechaAsignacion__c = MesSiguiente
                );
                
                Mensu.add(mes);
            }
        }
         upsert Mensu;
         delete mensuDelete;       
    }
    
        
    public static void updateM (List<String> idsAsig){
        
        List<Allocation__c>  asig = [Select Dedication__c,LastModifiedDate,Start_Date__c,End_Date__c,
                                     (select dedicacion__c, FechaAsignacion__c  from Mensualidades__r) from Allocation__c where id =: idsAsig];
        List<Mensualidad__c>mensu= new List <Mensualidad__c>();
        List<String> idsA = new List<String>();
        for(Allocation__c a:asig){
            Date modificacion=a.LastModifiedDate.Date();
            Date UltimoMes = date.newInstance(a.End_Date__c.year(),a.End_Date__c.month(),1);
            Date finalMes2= date.newInstance(a.End_Date__c.year(),a.End_Date__c.month()+1,1);
            Decimal dedicacionN = a.Dedication__c;
            if(modificacion > a.End_Date__c || modificacion < a.Start_Date__c){
                if(!idsA.contains(a.Id)){
                   idsA.add(a.id); 
                }
            }else{
                for(Mensualidad__c m:a.Mensualidades__r){
                    Decimal dedicacionO = m.Dedicacion__c;
                    if(m.FechaAsignacion__c.month()==modificacion.month() && m.FechaAsignacion__c.year()==modificacion.year() ){
                        if(a.Start_Date__c.month() == a.End_Date__c.month()){
                            m.Dedicacion__c=MediaDedi(modificacion, dedicacionO,dedicacionN,a.Start_Date__c,a.End_Date__c);
                        }else if (a.Start_Date__c.month() == modificacion.month()){
                            m.Dedicacion__c=MediaDedi(modificacion, dedicacionO,dedicacionN,a.Start_Date__c,null);
                        }else if (a.End_Date__c.month() == modificacion.month()){
                            m.Dedicacion__c=MediaDedi(modificacion, dedicacionO,dedicacionN,null,a.End_Date__c);
                        }else {
                            m.Dedicacion__c=MediaDedi(modificacion, dedicacionO,dedicacionN,null,null);
                            
                        }
                        mensu.add(m);
                    }else if(modificacion.month()<m.FechaAsignacion__c.month() && modificacion.year() <= m.FechaAsignacion__c.year()){
                        if(a.End_Date__c.month() == m.FechaAsignacion__c.month()){
                          m.Dedicacion__c = (a.Dedication__c/(UltimoMes.daysBetween(finalMes2)))*UltimoMes.daysBetween(a.End_Date__c+1);  
                        }else{
                          m.Dedicacion__c=a.Dedication__c;  
                        }
                        mensu.add(m);
                    }
                }
            }
        }
        if(idsA.size()>0){
            crearNuevoM(idsA);
        }
        if(mensu.size()>0){
           update mensu; 
        }
        
  }
     public static Decimal MediaDedi(Date modificacion,Decimal dedicacionO,Decimal DedicacionN,Date inicio,Date fin){
      
         Date antes;
         Date despues;
         Decimal media;
         Integer luego;
         Integer original;
         Integer diasMes = Date.newInstance(modificacion.year(),modificacion.month(),1).daysBetween(Date.newInstance(modificacion.year(),modificacion.month()+1,1));
         
         if(inicio == null && fin == null){
             antes = Date.newInstance(modificacion.year(),modificacion.month(),1);
             despues = Date.newInstance(modificacion.year(),modificacion.month()+1,1);
         }else if ( inicio !=null && fin == null) {
             antes = inicio;
             despues = Date.newInstance(modificacion.year(),modificacion.month()+1,1);
         }else if (inicio == null && fin != null){
             antes = Date.newInstance(modificacion.year(),modificacion.month(),1);
             despues = fin;
         }else{
             antes = inicio;
             despues = fin;             
         }
         original = antes.daysBetween(modificacion);
         luego = modificacion.daysBetween(despues);
         media = (dedicacionO*original + DedicacionN*luego )/diasMes;
         return media;
  }
    
    public static void borrar_mensualidades(List<String> asi){
              
   		List<Mensualidad__c> mensu = [Select Name, id from Mensualidad__c where Asignacion__c =: asi];

        delete mensu;
   }
    
    
    
}