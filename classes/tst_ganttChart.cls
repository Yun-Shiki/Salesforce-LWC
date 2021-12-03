@isTest
public with sharing class tst_ganttChart {
    @isTest
    static void ganttChart_getChartData() {
        Date d = Date.today();
        DateTime dt = DateTime.now();

        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern');
        insert r;

        Allocation__c a = new Allocation__c(
            Project__c = p.Id,
            Resource__c = r.Id,
            Start_Date__c = d,
            End_Date__c = d,
            Dedication__c = 100
        );
        insert a;

        Test.startTest();
        Map<String, Object> chartData = ganttChart.getChartData(
            null,
            String.valueOf(dt.getTime()),
            String.valueOf(dt.getTime()),
            1,
            new List<String>(),
            new List<String>(),
            '');
        Test.stopTest();

        System.assert(chartData.containsKey('projects'));
        List<Object> projects = (List<Object>)chartData.get('projects');
        System.assertEquals(1, projects.size());
        Map<String, Object> projectMap = (Map<String, Object>)projects.get(0);
        System.assertEquals(p.Id, (String)projectMap.get('Id'));

        System.assert(chartData.containsKey('resources'));
        List<Object> resources = (List<Object>)chartData.get('resources');
        System.assertEquals(1, resources.size());
        Map<String, Object> resourceMap = (Map<String, Object>)resources.get(0);
        System.assertEquals(r.Id, (String)resourceMap.get('Id'));

        System.assert(chartData.containsKey('roles'));
        Set<String> roles = (Set<String>)chartData.get('roles');
        System.assertEquals(1, roles.size());
        System.assert(roles.contains(r.Rol__c));
    }

    @isTest
    static void ganttChart_getChartData_withFilters() {
        Date d = Date.today();
        DateTime dt = DateTime.now();

        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern');
        insert r;

        Allocation__c a = new Allocation__c(
            Project__c = p.Id,
            Resource__c = r.Id,
            Effort__c = 'High',
            Status__c = 'Active',
            Start_Date__c = d,
            End_Date__c = d);
        insert a;

        Test.startTest();
        Map<String, Object> chartData = ganttChart.getChartData(
            r.Id,
            String.valueOf(dt.getTime()),
            String.valueOf(dt.getTime()),
            1,
            new List<String> { p.Id },
            new List<String> { r.Rol__c },
            a.Status__c);
        Test.stopTest();

        System.assert(chartData.containsKey('projects'));
        List<Object> projects = (List<Object>)chartData.get('projects');
        System.assertEquals(1, projects.size());
        Map<String, Object> projectMap = (Map<String, Object>)projects.get(0);
        System.assertEquals(p.Id, (String)projectMap.get('Id'));

        System.assert(chartData.containsKey('resources'));
        List<Object> resources = (List<Object>)chartData.get('resources');
        System.assertEquals(1, resources.size());
        Map<String, Object> resourceMap = (Map<String, Object>)resources.get(0);
        System.assertEquals(r.Id, (String)resourceMap.get('Id'));

        System.assert(chartData.containsKey('roles'));
        Set<String> roles = (Set<String>)chartData.get('roles');
        System.assertEquals(1, roles.size());
        System.assert(roles.contains(r.Rol__c));
    }

    @isTest
    static void ganttChart_getResources() {
        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern'
        );
        insert r;

        Test.startTest();
        List<Object> resources = ganttChart.getResources();
        Test.stopTest();

        System.assertEquals(1, resources.size());
        System.assertEquals(r.Id, ((Map<String, Object>)resources.get(0)).get('Id'));
        System.assertEquals(r.Rol__c, ((Map<String, Object>)resources.get(0)).get('Rol__c')); 
    }
    
    @isTest
    static void ganttChart_getProjects() {
        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Test.startTest();
        List<Project__c> projects = ganttChart.getProjects();
        Test.stopTest();

        System.assertEquals(1, projects.size());
        System.assertEquals(p.Id, projects.get(0).Id);
    }
    
    @isTest
    static void ganttChart_saveAllocation() {
        Date d = Date.today();
        DateTime dt = DateTime.now();

        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern');
        insert r;

        String effort = 'High';
        String status = 'Active';
        Decimal dedication = 100;

        Test.startTest();
        ganttChart.saveAllocation(null, p.Id, r.Id, effort, status, String.valueOf(dt.getTime()), String.valueOf(dt.getTime()),dedication);
        Test.stopTest();

        List<Allocation__c> allocations = [SELECT Id, Project__c, Resource__c, Effort__c, Status__c, Start_Date__c, End_Date__c
                                           FROM Allocation__c];
        System.assertEquals(1, allocations.size());
        System.assertEquals(p.Id, allocations.get(0).Project__c);
        System.assertEquals(r.Id, allocations.get(0).Resource__c);
        System.assertEquals(effort, allocations.get(0).Effort__c);
        System.assertEquals(status, allocations.get(0).Status__c);
    }

    @isTest
    static void ganttChart_saveAllocation_update() {
        Date d = Date.today();
        DateTime dt = DateTime.now();

        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern');
        insert r;

        String effort = 'High';
        String status = 'Inactive';
        Decimal dedication = 100;

        Allocation__c a = new Allocation__c(
            Project__c = p.Id,
            Resource__c = r.Id,
            Effort__c = effort,
            Status__c = 'Active',
            Dedication__c = 100,
            Start_Date__c = d,
            End_Date__c = d);
        insert a;

        Test.startTest();
        ganttChart.saveAllocation(a.Id, null, r.Id, effort, status, String.valueOf(dt.getTime()), String.valueOf(dt.getTime()),dedication);
        Test.stopTest();

        List<Allocation__c> allocations = [SELECT Id, Project__c, Resource__c, Effort__c, Status__c, Start_Date__c, End_Date__c
                                           FROM Allocation__c];
        System.assertEquals(1, allocations.size());
        System.assertEquals(a.Id, allocations.get(0).Id);
        System.assertEquals(null, allocations.get(0).Project__c);
        System.assertEquals(r.Id, allocations.get(0).Resource__c);
        System.assertEquals(effort, allocations.get(0).Effort__c);
        System.assertEquals(status, allocations.get(0).Status__c);
    }

    @isTest
    static void ganttChart_deleteAllocation() {
        Date d = Date.today();
        DateTime dt = DateTime.now();
        Project__c p = new Project__c(
            Name='Test Project',
            Color__c='Orange');
        insert p;

        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern');
        insert r;

        Allocation__c a = new Allocation__c(
            Project__c = p.Id,
            Resource__c = r.Id,
            Start_Date__c = d,
            End_Date__c = d);
        insert a;

        Test.startTest();
        ganttChart.deleteAllocation(a.Id);
        Test.stopTest();

        List<Allocation__c> allocations = [SELECT Id FROM Allocation__c];

        System.assertEquals(0, allocations.size());
    }
    @isTest
    static void test_saveVacations(){
        Date d = date.today();
        DateTime dt = DateTime.now();
        
        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern'
        );
        insert r;
        Project__c p = new Project__c(
            Name='Vacaciones',
            Color__c='Orange');
        insert p;
        Vacaciones__c v = new Vacaciones__c(
            Name = 'Test vacaciones',
            Inicio_de_vacaciones__c = d,
            Final_de_vacaciones__c = d,
            Empleado__c = r.Id,
            Tipo_de_vacaciones__c = 'Ordinarias');
        insert v;
        HTCalculo ca = new HTCalculo();
        Integer testSihayVaca = ca.SihayVaca(d,d,d,d);
        
        Test.startTest();
        ganttChart.saveVacation(null,v.Name,v.Empleado__c, String.valueOf(dt.getTime()), String.valueOf(dt.getTime()),v.Tipo_de_vacaciones__c);
        Test.stopTest();
        List<Vacaciones__c> Vacations = [select id,Name,Empleado__c,Inicio_de_vacaciones__c,Final_de_vacaciones__c,Tipo_de_vacaciones__c from Vacaciones__c];
        
        System.assertEquals(2, Vacations.size());
        System.assertEquals(r.Id, Vacations.get(0).Empleado__c);
        System.assertEquals(v.Tipo_de_vacaciones__c, vacations.get(0).Tipo_de_vacaciones__c);
        System.assertEquals(1, testSihayvaca);
       
        
    }
    @isTest 
    public static void saveVacation_Update(){
        Date d = Date.today();
        DateTime dt = DateTime.now();
        
        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern'
        );
        insert r;
        Project__c p = new Project__c(
            Name='Vacaciones',
            Color__c='Orange');
        insert p;        
        String nombre = 'Test vacaciones';
        String tipo = 'Ordinarias';
        Vacaciones__c v = new Vacaciones__c(
            Name = nombre,
            Inicio_de_vacaciones__c = d,
            Final_de_vacaciones__c = d,
            Empleado__c = r.Id,
            Tipo_de_vacaciones__c = 'Boda');
        insert v;        
        Test.startTest();
        ganttChart.saveVacation(v.Id, nombre, r.Id, String.valueOf(dt.getTime()), String.valueOf(dt.getTime()), tipo);
        Test.stopTest();
        List<Vacaciones__c> Vacations = [select id,Name,Empleado__c,Inicio_de_vacaciones__c,Final_de_vacaciones__c,Tipo_de_vacaciones__c from Vacaciones__c];
        System.assertEquals(1, Vacations.size());
        System.assertEquals(r.Id, Vacations.get(0).Empleado__c);
        System.assertEquals(tipo, vacations.get(0).Tipo_de_vacaciones__c);
    }
    @isTest
    public static void deleteVacaciones(){
        Date d = date.today();
        DateTime dt = DateTime.now();
        
        Resource__c r = new Resource__c(
            Name='Test Resource',
            Rol__c='Intern'
        );
        insert r;
        Project__c p = new Project__c(
            Name='Vacaciones',
            Color__c='Orange');
        insert p;
        
        Vacaciones__c v = new Vacaciones__c(
            Name = 'Test vacaciones',
            Inicio_de_vacaciones__c = d,
            Final_de_vacaciones__c = d,
            Empleado__c = r.Id,
            Tipo_de_vacaciones__c = 'Ordinarias');
        insert v;
        Test.startTest();
        ganttChart.deleteVacation(v.Id);
        Test.stopTest();
        List<Vacaciones__c> va = [select id from Vacaciones__c];
        
        System.assertEquals(0, va.size());
    }
    @isTest
    public static void TestDiasWeekend(){
        Date d = Date.today();
        Date d2 = Date.today()+5;
        
        integer test = DiasWeekend.getWorkingDays(d,d2);
        
    }
    
    @isTest
    public static void TestCertificacion(){
        
        Resource__c r = new Resource__c(
            Name='Test',
            Rol__c='Intern'
        );
        insert r;
       Test.startTest(); 
      Certificaciones__c c=new Certificaciones__c(Empleado__c=r.id,Name='Test',Tipo_de_certificacion__c='Salesforce',
                                                  Certificacion_Salesforce__c='JavaScript Developer I');
        
      Certificaciones__c c2=new Certificaciones__c(Empleado__c=r.id,Name='Test2',Tipo_de_certificacion__c='Otras', 
                                                Otra__c='Python Developer');
        
        insert c; 
        insert c2;
        Test.stopTest();
    }
  @isTest 
    public static void TestMensualidad (){
       
        Date d = Date.today();  
        Resource__c r = new Resource__c(Name='Test', Rol__c='Intern');
       insert r;
            
        Project__c p = new Project__c(Name='Project', Color__c='Orange');
       insert p;
            
        Allocation__c a= new Allocation__c(
            Name = 'Test',
            Project__c = p.Id,
            Resource__c = r.Id,
            Start_Date__c = d,
            End_Date__c = d,
            Effort__c='Low',
            Status__c='Active'  );
       insert a;
       
       a.End_Date__c = d.addMonths(2);
       update a;
        
    }
    
    @isTest
    public static void Convertir_candidato() {

        date hoy= date.today();
        
        Project__c p = new Project__c(Name='Test Project', Color__c='Orange', fin_del_proyecto__c = hoy, Inicio_del_proyecto__c=hoy);
        insert p;

        Vacantes__c a = new Vacantes__c(Proyecto__c = p.Id, estado__c = 'abierto');
        insert a;
        
        Candidato__c c = new Candidato__c(Name='paco', Rol__c='Intern', fase__c = 'Inscrito', Vacantes__c= a.id);
        insert c;
        
        Skill_Book__c b = new Skill_Book__c(Name='ingles', area_de_skill__C = 'Idioma', tipo_de_skill__c= 'Inglés', nivel_de_skill__c='C2');
        insert b;
                
        Skill__c sk = new Skill__c(Name='JS', Skill_Book__c = b.Id, candidato__c = c.id);
        insert sk;
        
        c.fase__c = 'contratado';
        update c;
        
        List<Resource__c> emp = [select name, id from Resource__c];
        System.assertEquals(1, emp.size());
        System.assertEquals(c.name, emp[0].name);
        
        List<Allocation__c> asig = [select start_date__c, end_date__c, project__c, id from allocation__c];
        System.assertEquals(p.id, asig[0].project__c);
        System.assertEquals(p.Inicio_del_proyecto__c, asig[0].start_date__c);


    }
   /*  @isTest 
    public static void SumarImporteCalculado(){
        
        Date hoy=DATE.TODAY();
        
        Account acc = new Account(Name='Account' );
        insert acc;      
        Opportunity opp= new Opportunity(Name='Test', closeDate=hoy,Account=acc,StageName='Calificación');
       	insert opp;
        Rol__c rol = new Rol__c(Name='Rol', Rol__c='Jefe de Proyecto', FTE__c=1,Jornada__c='10', Precio_Medio_Jornada__c='400',Oportunidad__c=opp.id);
        insert rol;
        
        rol.FTE__c=0.5;
        update rol;
        
    }*/
}