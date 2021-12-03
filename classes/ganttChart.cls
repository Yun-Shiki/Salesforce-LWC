public with sharing class ganttChart {
    @AuraEnabled
    public static Map<String, Object> getChartData(String recordId, String startTime, String endTime, Integer slotSize, List<String> filterProjects, List<String> filterRoles, String filterStatus) {
        Map<String, Object> data = new Map<String, Object>();
        System.debug(filterRoles);
        String query = 'SELECT Resource__c, Resource__r.Name, Resource__r.Active__c, Resource__r.Rol__c, Project__c, Project__r.Name, Project__r.Active__c, Project__r.Color__c, Start_Date__c, End_Date__c, Status__c, Effort__c,Dedication__c,Vacaciones__r.Tipo_de_vacaciones__c FROM Allocation__c WHERE Start_Date__c <= :endDate AND End_Date__c >= :startDate AND (Project__c = NULL OR Project__r.Active__c = TRUE) AND Resource__r.Active__c = TRUE';
        List<Allocation__c> allocations = new List<Allocation__c>();
        Map<String, Object> projectById = new Map<String, Object>();
        Map<String, Object> resourceById = new Map<String, Object>();
        Set<String> roles = new Set<String>();

        if (!filterProjects.isEmpty()) {
            query += ' AND Project__c IN :filterProjects';
        }
        /*
        if (!filterProjectRecords.isEmpty()) {
            query += ' AND Project__c IN :filterProjectRecords';
        }
        */
        if (!filterRoles.isEmpty()) {
            query += ' AND Resource__r.Rol__c IN :filterRoles';
        }
        if (String.isNotEmpty(filterStatus)) {
            query += ' AND Status__c = :filterStatus';
        }
        	Date startDate;

        if (String.isNotEmpty(startTime) &&  String.isNotEmpty(endTime)) {
            startDate = DateTime.newInstance(Long.valueOf(startTime)).date();
            Date endDate = DateTime.newInstance(Long.valueOf(endTime)).date();
            Integer days = startDate.daysBetween(endDate)+1;
            slotSize = Integer.valueOf(slotSize);
            Decimal slots = days / slotSize;
            
            // Overview View
            if (String.isEmpty(recordId)) {
                query += ' ORDER BY Resource__r.Name, Project__r.Name NULLS FIRST, Start_Date__c';
                System.debug(query);
                System.debug(startTime);
                System.debug(endTime);
                System.debug(slotSize);
                allocations = Database.query(query);

                // display all active resources
                for (Object r : ganttChart.getResourcesF(filterRoles)) {
                    Map<String, Object> resource = (Map<String, Object>)r;
                    resourceById.put((String)resource.get('Id'), new Map<String, Object> {
                        'Id' => resource.get('Id'),
                        'Name' => resource.get('Name'),
                        'Rol__c' => resource.get('Rol__c'),
                        'allocationsByProject' => new Map<String, Object>()
                    });
                }
            } else {
                if (Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('Project__c')) {
                    data.put('projectId', recordId);
                }

                query += ' AND (Project__c = :recordId OR Resource__c = :recordId)';
                query += ' ORDER BY Resource__r.Name, Project__r.Name NULLS FIRST, Start_Date__c';

                allocations = Database.query(query);

                // empty state on resource page
                if (allocations.isEmpty() && Id.valueOf(recordId).getSobjectType().getDescribe().getName().endsWith('Resource__c')) {
                    Resource__c resource = [SELECT Id, Name, Active__c, Rol__c
                                            FROM Resource__c
                                            WHERE Id = :recordId];

                    resourceById.put(resource.Id, new Map<String, Object> {
                        'Id' => resource.Id,
                        'Name' => resource.Name,
                        'Rol__c' => resource.Rol__c,
                        'allocationsByProject' => new Map<String, Object>()
                    });
                }
            }
            
            
            // organize allocations by resource and project
            for (Allocation__c allocation : allocations) {
                if (!resourceById.containsKey(allocation.Resource__c)) {
                    resourceById.put(allocation.Resource__c, new Map<String, Object> {
                        'Id' => allocation.Resource__c,
                        'Name' => allocation.Resource__r.Name,
                        'Rol__c' => allocation.Resource__r.Rol__c,
                        'allocationsByProject' => new Map<String, Object>()
                    });
                }

                Map<String, Object> resource = (Map<String, Object>)resourceById.get(allocation.Resource__c);
                Map<String, Object> allocationsByProject = (Map<String, Object>)resource.get('allocationsByProject');
               
                
                if (!allocationsByProject.containsKey(allocation.Project__c)) {
                    allocationsByProject.put(allocation.Project__c, new List<Object>());
                }

                projectById.put(allocation.Project__c, new Map<String, Object> {
                    'Id' => allocation.Project__c,
                    'Name' => allocation.Project__r.Name +' ' + allocation.Dedication__c + '%'
                });

                List<Object> projectAllocation = (List<Object>)allocationsByProject.get(allocation.Project__c);
                Decimal slotMes,left,right;
                if(slotSize==30){
                    left = startDate.monthsBetween(allocation.Start_Date__c)-1;
                    right = startDate.monthsBetween(allocation.End_Date__c)-1;
                    System.debug('Left : ' + left +'Right : ' +right);
                }else if (slotSize == 1){
                left = Decimal.valueOf(startDate.daysBetween(allocation.Start_Date__c)) / slotSize;
                System.debug('Left es sin redondear: ' + left);
                left = left.round(System.RoundingMode.FLOOR)-1;
                System.debug('Left es: ' + left);
                
                right = Decimal.valueOf(startDate.daysBetween(allocation.End_Date__c)) / slotSize;
                System.debug('Right es sin redondear: ' + right);
                right = right.round(System.RoundingMode.FLOOR)-1;
                System.debug('Right es: ' + right);
                }else{
                left = Decimal.valueOf(startDate.daysBetween(allocation.Start_Date__c)) / slotSize;
                System.debug('Left es sin redondear: ' + left);
                left = left.round(System.RoundingMode.FLOOR);
                System.debug('Left es: ' + left);
                
                right = Decimal.valueOf(startDate.daysBetween(allocation.End_Date__c)) / slotSize;
                System.debug('Right es sin redondear: ' + right);
                right = right.round(System.RoundingMode.FLOOR);
                System.debug('Right es: ' + right);

                    
                }

                system.debug('allocation.Project__r.Name: ' + allocation.Project__r.Name + allocation.Dedication__c);
                
                string formatoNombre;
                if(allocation.Project__r.Name=='Vacaciones'){
                    
                    formatoNombre=allocation.Project__r.Name + ' ' +  allocation.Vacaciones__r.Tipo_de_vacaciones__c;
                }
               else if(allocation.Project__r.Name=='Festivos'){
                    
                  formatoNombre='Festivo ';
                }
                                   
               else{
                    formatoNombre=allocation.Project__r.Name +' ' + allocation.Dedication__c + '%';
                }

                projectAllocation.add(new Map<String, Object> {
                    'Id' => allocation.Id,
                    'Start_Date__c' => allocation.Start_Date__c,
                    'End_Date__c' => allocation.End_Date__c,
                    'Status__c' => allocation.Status__c,
                    'Effort__c' => allocation.Effort__c,
                    'Dedication__c'=> allocation.Dedication__c,
                    'projectName' => formatoNombre,
                    'color' => allocation.Project__r.Color__c,
                    'left' => left,
                    'right' => right
                });

                roles.add(allocation.Resource__r.Rol__c);
            }
        }

        data.put('projects', projectById.values());
        data.put('resources', resourceById.values());
        data.put('roles', roles);
        
        return data;
    }

    @AuraEnabled
    public static List<Object> getResources() {
        List<Object> resources = new List<Object>();

        for (Resource__c r : [SELECT Id, Name, Rol__c
                              FROM Resource__c
                              WHERE Active__c = true
                              ORDER BY Name]) {
            resources.add(new Map<String, Object> {
                'Id' => r.Id,
                'Name' => r.Name,
                'Rol__c' => r.Rol__c
            });
        }

        return resources;
    }
    public static List<Object> getResourcesF(List<String> filterRoles) {
        List<Object> resources = new List<Object>();
        List<Resource__c> re = new List<Resource__c>();
        String query;
        if(!filterRoles.isEmpty()){
            query = 'SELECT Id, Name, Rol__c FROM Resource__c WHERE Active__c = true and Rol__c in :filterRoles  ORDER BY Name';
        }else{
            query = 'SELECT Id, Name, Rol__c FROM Resource__c WHERE Active__c = true  ORDER BY Name';
        }
         re = Database.query(query);   

        for (Resource__c r : re) {
            resources.add(new Map<String, Object> {
                'Id' => r.Id,
                'Name' => r.Name,
                'Rol__c' => r.Rol__c
            });
        }

        return resources;
    }

    @AuraEnabled
    public static List<Project__c> getProjects() {
        return [SELECT Id, Name
                FROM Project__c
                WHERE Active__c = true
                ORDER BY Name];
    }
    @AuraEnabled
    public static void saveVacation(Id vacacionId,String Name, ID resourceId,String startDate,String endDate,String tipo){
        Vacaciones__c vacaciones = new Vacaciones__c(
            Inicio_de_vacaciones__c = DateTime.newInstance(Long.valueOf(startDate)).date(),
            Final_de_vacaciones__c = DateTime.newInstance(Long.valueOf(endDate)).date()
        );
        if(null != vacacionId){
            vacaciones.Id = vacacionId;
        }else {
            vacaciones.Empleado__c = resourceId;
        }
        if(String.isNotEmpty(Name)){
            vacaciones.Name = Name;
        }
        if(String.isNotEmpty(tipo)){
            vacaciones.Tipo_de_vacaciones__c = tipo;
        }
        upsert vacaciones;
    }
    @AuraEnabled
    public static void guardarVacaciones(ID userId,String startDate, String endDate,String tipo){
        List<User> usuario =[Select Email,Name from user where id =: userId];
        String userEmail = usuario[0].Email;
        Id recordID =[Select id from Resource__c where Name =: usuario[0].Name][0].id;
        Vacaciones__c vacaciones = new Vacaciones__c(
            Inicio_de_vacaciones__c = DateTime.newInstance(Long.valueOf(startDate)).date()+1,
            Final_de_vacaciones__c = DateTime.newInstance(Long.valueOf(endDate)).date(),
            Tipo_de_vacaciones__c = tipo,
            Empleado__c = recordID,
            Name = tipo,
            Estado__c = 'Pendientes'
        );
        insert vacaciones;
    }
    @AuraEnabled
    public static void borrarV(List<Vacaciones__c> va){
        system.debug(va);
        delete va;
    }
    @AuraEnabled(cacheable=true)
    public static Decimal diasPend(ID userId){
        List<User> usuario =[Select Email,Name from user where id =: userId];
        String userEmail = usuario[0].Email;
        Resource__c record =[Select id,Vacaciones_pendientes__c,Vacaciones_totales__c from Resource__c where Email__c =: userEmail];
        
        return record.Vacaciones_totales__c - record.Vacaciones_pendientes__c;
    }
    @AuraEnabled(cacheable=true)
    public static Decimal diasTota(ID userId){
        List<User> usuario =[Select Email,Name from user where id =: userId];
        String userEmail = usuario[0].Email;
        Resource__c record =[Select id,Vacaciones_totales__c from Resource__c where Email__c =: userEmail];
        
        return record.Vacaciones_totales__c;
    }
    @AuraEnabled(cacheable=true)
    public static List<Vacaciones__c> getVacation(){
       
        return[Select Name,Inicio_de_vacaciones__c,Final_de_vacaciones__c,Dias_solicitados__c,Estado__c,CreatedDate from Vacaciones__c where Son_mis_vacaciones__c = true];
    }
    @AuraEnabled
    public  static void guardarCertificacion(ID Id, String Tipo, String Certif, String otra,String base64, String filename){ 
        ContentVersion cv = createContentVersion(base64, filename);
		       
        User usuario =[select Email from User where ID=:Id];

        Resource__c emp =[select Id, Email__c from Resource__c where Email__c =: usuario.Email];
        
        Certificaciones__c cert = new Certificaciones__c ( Empleado__c = emp.id, Certificacion_Salesforce__c = Certif,
            Tipo_de_certificacion__c = Tipo, Otra__c = otra);
        
        insert cert;
        ContentDocumentLink cdl = createContentLink(cv.Id, cert.Id);
	}
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        try {
            insert cv;
            return cv;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
  
    }
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            return cdl;
        } catch(DMLException e) {
            System.debug(e);
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveFestival(String startDate,String endDate){
        Project__c p = [select id from Project__c where NAME ='Festivos'];
        String idFestivo = p.id;
        String effort = 'High';
        String Status = 'Active';
        List <Resource__c> emp = [Select id from resource__c];
        List<Allocation__c> asi = new List<Allocation__c>();
        for(Resource__c e:emp){
            saveAllocation(null,idFestivo,e.Id,effort,status,startDate,endDate,0);
        }
        
    }

    @AuraEnabled
    public static void saveAllocation(Id allocationId, Id projectId, Id resourceId, String effort, String status, String startDate, String endDate,Decimal dedication) {
        Allocation__c allocation = new Allocation__c(
            Start_Date__c = DateTime.newInstance(Long.valueOf(startDate)).date()+1,
            End_Date__c = DateTime.newInstance(Long.valueOf(endDate)).date()+1
        );

        // update allocation
        if (null != allocationId) {
            allocation.Id = allocationId;
        } else {
            if (null != projectId) {
                allocation.Project__c = projectId;
            }

            allocation.Resource__c = resourceId;
        }

        if (String.isNotEmpty(effort)) {
            allocation.Effort__c = effort;
        }
        if (String.isNotEmpty(status)) {
            allocation.Status__c = status;

            // remove project
            if ('Unavailable' == status) {
                allocation.Project__c = null;
            }
        }
        if(dedication == null){
            allocation.Dedication__c = 100;
        }else{
            allocation.Dedication__c = dedication; 
        }
        
        
        upsert allocation;
    }
        @AuraEnabled
    public static void saveAllocationV(Id allocationId, Id projectId, Id resourceId, String effort, String status, Date startDate, Date endDate,Decimal dedication, String VacacionesId) {
        Allocation__c allocation = new Allocation__c(
            Start_Date__c = startDate,
            End_Date__c = endDate
        );

        // update allocation
        if (null != allocationId) {
            allocation.Id = allocationId;
        } else {
            if (null != projectId) {
                allocation.Project__c = projectId;
            }

            allocation.Resource__c = resourceId;
            allocation.Vacaciones__c = vacacionesId;
        }

        if (String.isNotEmpty(effort)) {
            allocation.Effort__c = effort;
        }
        if (String.isNotEmpty(status)) {
            allocation.Status__c = status;

            // remove project
            if ('Unavailable' == status) {
                allocation.Project__c = null;
            }
        }
            allocation.Dedication__c = dedication; 
       
        upsert allocation;
    }
    

    @AuraEnabled
    public static void deleteAllocation(Id allocationId) {
        delete new Allocation__c(Id = allocationId);
    }
    @AuraEnabled
    public static void deleteVacation(ID vacationId){
        delete new Vacaciones__c(Id = vacationId);
    }
    
}