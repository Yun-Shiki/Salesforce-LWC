import { LightningElement,wire,track} from 'lwc';
import Id from '@salesforce/user/Id';
import present from '@salesforce/apex/ControladorListproyecto.presentP';
import past from '@salesforce/apex/ControladorListproyecto.pastP';
import futur from '@salesforce/apex/ControladorListproyecto.futurP';
import NAME_FIELD from '@salesforce/schema/User.Name';
import Lista from '@salesforce/apex/ControladorListproyecto.ListaEmpleados';
import ListaAsig from '@salesforce/apex/ControladorListproyecto.AsignacionList';


import {
    getRecord
} from 'lightning/uiRecordApi';
const COLS =[
    {label:'Nombre del proyecto',fieldName:'Name',type:'text'}
];
export default class ListaProyecto extends LightningElement {
    name;
    @wire(present,{userId:Id})
    presentList;
    @wire(past,{userId:Id})
    pastList;
    @wire(futur,{userId:Id})
    futurList;
    @wire(getRecord, {
        recordId: Id,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.name = data.fields.Name.value;
        }
    }
    cols=COLS;
    error;
    Asignaciones;
    projectName;
    descripcion;
    carpeta;
    Empleado;
    JefeProyecto;
    ListaEmpleados;
    Email;
    esEmpleado;
    inicioProyecto;
    finalProyecto;
    handleProjectView(event){
        
        
        var projecto = event.target.value;
        this.projectName = projecto.Name;
        this.descripcion = projecto.Descripcion__c;
        this.carpeta = projecto.URL_carpeta__c;
        this.getAsignacion(projecto.Id);
       
        
        if(this.carpeta == null){
            this.carpeta ='No hay archivos de este proyecto';
        }
        
        if(this.name===projecto.Jefe_de_proyecto__r.Name){
           this.esEmpleado=false;
            this.getProject(projecto.Id);

            this.Empleado="Empleados";
        }else{

            this.esEmpleado=true;
            this.Empleado="Jefe de proyecto";
            this.JefeProyecto=projecto.Jefe_de_proyecto__r.Name;
            this.Email=projecto.Jefe_de_proyecto__r.Email__c;     
        }

       
        let inicio = new Date(projecto.Inicio_del_proyecto__c);
        this.inicioProyecto= inicio.getDate()+ "/" + (inicio.getMonth()+1)+ "/" + inicio.getFullYear();
        let final = new Date(projecto.Fin_del_proyecto__c);
        this.finalProyecto= final.getDate()+ "/" + (final.getMonth()+1)+ "/" + final.getFullYear();

        this.template.querySelector(".project_view_modal").show();

        

    }



    getAsignacion(Project){

        ListaAsig({
            userId:Id, proyecto:Project
        
        })
        .then(result =>{
            let AsignacionData = JSON.parse(JSON.stringify(result));
            this.Asignaciones = AsignacionData;
            let inicioa;
            let fina;
           
            for(let i=0; i<AsignacionData.length;i++){

                let datos = AsignacionData[i];
                inicioa = new Date(datos.Start_Date__c);
                datos.Start_Date__c= inicioa.getDate()+ "/" + (inicioa.getMonth()+1)+ "/" + inicioa.getFullYear();
                fina = new Date(datos.End_Date__c);
                datos.End_Date__c= fina.getDate()+ "/" + (fina.getMonth()+1)+ "/" + fina.getFullYear();
                
            }
            this.Asignaciones = AsignacionData;
            
          })
          .catch(error => {
            this.error = error;

        });      
    
    }
   

    getProject(Project){
        Lista({
            proyecto:Project
        })
        .then(result =>{
            let ProjectData = JSON.parse(JSON.stringify(result));
            this.ListaEmpleados = ProjectData;
           
          })
          .catch(error => {
            this.error = error;

        });      
    }


}