import { LightningElement } from 'lwc';
import saveVacacion from "@salesforce/apex/ganttChart.guardarVacaciones";
import userId from '@salesforce/user/Id';

export default class AddVacaciones extends LightningElement {
  type='Ordinarias';
  vacationOptions = [
    {
      label:'Boda',
      value:'	Boda'
    },
    {
      label:'Enfermedad',
      value:'	Enfermedad'
    },
    {
      label:'Familiar',
      value:'	Familiar'
    },
    {
      label:'Mudanza',
      value:'	Mudanza'
    },
    {
      label:'Nacimiento',
      value:'	Nacimiento'
    },
    {
      label:'Ordinarias',
      value:'	Ordinarias'
    }
  ];
  dias = {};
  setType(event){
    this.type = event.currentTarget.value;
  }
  saveVacation(){
    const startDate = new Date(this.dias.startDate  + "T00:00:00");
    const endDate = new Date(this.dias.endDate + "T00:00:00");
    saveVacacion({
      userId: userId,
      startDate: startDate.getTime()+startDate.getTimezoneOffset()*60*1000+"",
      endDate: endDate.getTime()+endDate.getTimezoneOffset()*60*1000+"",
      tipo:this.type
    });
      
    this.template.querySelector(".create-vacaciones-modal").hide();
    location.reload();
  
    
  }
  DiaCambiado(event){
    this.dias[event.target.dataset.field]=event.target.value;
  }

  openAddVacationModal() {
      this.template.querySelector(".create-vacaciones-modal").show();
    }
}