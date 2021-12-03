public class ganttSide {
    @AuraEnabled
    public static Map<String, Object> getChartData(String recordId, String startTime, String endTime, Integer slotSize,ID userId) {
        System.debug('ID ' + userid);
        List<User> usuario =[Select Email from user where id =: userId];
        String userEmail = usuario[0].Email;
        System.debug('Email ' + userEmail);
        Map<String, Object> data = new Map<String, Object>();
        String query = 'SELECT Resource__c, Resource__r.Name, Resource__r.Active__c, Resource__r.Rol__c, Project__c, Project__r.Name, Project__r.Active__c, Project__r.Color__c, Start_Date__c, End_Date__c, Status__c, Effort__c,Dedication__c,Vacaciones__r.Tipo_de_vacaciones__c FROM Allocation__c WHERE Start_Date__c <= :endDate AND End_Date__c >= :startDate AND (Project__c = NULL OR Project__r.Active__c = TRUE) AND Resource__r.Active__c = TRUE AND( Resource__r.Email__c = :userEmail or Project__r.Jefe_de_proyecto__r.Email__c = :userEmail) ';
        List<Allocation__c> allocations = new List<Allocation__c>();
        Map<String, Object> projectById = new Map<String, Object>();
        Map<String, Object> resourceById = new Map<String, Object>();
        Set<String> roles = new Set<String>();
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
                for (Object r : ganttSide.getResources(userEmail)) {
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
    public static List<Object> getResources(String userEmail) {
        System.debug('Email '+ userEmail);
        List<Allocation__c> asi = [Select Resource__c from Allocation__c where Resource__r.Email__c = :userEmail or Project__r.Jefe_de_proyecto__r.Email__c = :userEmail];
        List<String> idsEmpl = new List<String>();
        for(Allocation__c a:asi){
            idsEmpl.add(a.Resource__c);
        }
        List<Object> resources = new List<Object>();
        List<Resource__c> re = [SELECT Id, Name, Rol__c FROM Resource__c WHERE Active__c = true and id =: idsEmpl  ORDER BY Name];
        for (Resource__c r : re) {
            resources.add(new Map<String, Object> {
                'Id' => r.Id,
                'Name' => r.Name,
                'Rol__c' => r.Rol__c
            });
        }

        return resources;
    }

}