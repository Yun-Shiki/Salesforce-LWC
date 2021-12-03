import { LightningElement,wire } from 'lwc';
import userId from '@salesforce/user/Id';
import diasPend from "@salesforce/apex/ganttChart.diasPend";
import diasTota from "@salesforce/apex/ganttChart.diasTota";

export default class DiasVacaciones extends LightningElement {
    @wire(diasPend,{userId:userId})
    dias;
    @wire(diasTota,{userId:userId})
    diaT;
}