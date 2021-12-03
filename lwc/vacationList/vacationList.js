import { LightningElement,wire } from 'lwc';
import getVacaciones from "@salesforce/apex/ganttChart.getVacation";
import {loadStyle} from 'lightning/platformResourceLoader';
import deleteVa from "@salesforce/apex/ganttChart.borrarV";
import COLORS from '@salesforce/resourceUrl/COLOR'
const COLS =[
    {label:'Nombre',fieldName:'Name',type:'text'},
    {label:'Inicio de vacaciones',fieldName:'Inicio_de_vacaciones__c',type: "date-local",
    typeAttributes:{
        month: "2-digit",
        day: "2-digit"
    }},
    {label:'Final de vacaciones',fieldName:'Final_de_vacaciones__c',type: "date-local",
    typeAttributes:{
        month: "2-digit",
        day: "2-digit"
    }},
    {label:'Dias solicitados',fieldName:'Dias_solicitados__c',type:'text'},
    {label:'Estado',fieldName:'Estado__c',type:'text',cellAttributes:{
        class:{fieldName:'statusColor'}
    }},
    {label:'Dias de solicitud',fieldName:'CreatedDate',type: "date-local",
    typeAttributes:{
        month: "2-digit",
        day: "2-digit"
    }}
];

export default class VacationList extends LightningElement {
    listV;
    cols = COLS;
    isCssLoaded = false;
    @wire (getVacaciones)
    vacationHandler({data,error}){
        if(data){
            this.listV = data.map(item =>{
                let statuColor;
                if(item.Estado__c == "Aceptadas"){
                    statuColor = "slds-text-color_success";
                    // "datadable-green";
                }else if(item.Estado__c == "Rechazadas"){
                    statuColor = "slds-text-color_error";
                    //"datadable-red";
                }
                return{ ...item,
                    "statusColor":statuColor
                }
            });

        }
        if(error){
            console.error(error);
        }

    };
    
    selectedV;
    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, COLORS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }
    deleteV(){
        this.selectedV = this.template.querySelector('lightning-datatable').getSelectedRows();
        deleteVa({
            va:this.selectedV
        });
        location.reload();

    }
}