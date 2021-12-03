import { LightningElement,wire,track} from 'lwc';
import Id from '@salesforce/user/Id';
import Lista from '@salesforce/apex/listaCasos.casosList';


COLS=[
    {label: 'Tipo', fieldName:'Type', type:'text' },
    {label:'Estado', fieldName:'Status', type:'text'},
    {label:'Asunto', fieldName:'Subject', type:'text'},
    {label:'Descripción', fieldName:'Description', type:'text'}

];


export default class ListaCasos extends LightningElement {
    

    name;
    @wire(Lista,{userId:Id})
    casosList;
   
    
    cols=COLS;
    /*Tipo;
    Status;
    Asunto;
    Descripcion;
    ListaCasos;
    handleCaseView(event){
               
        var caso = event.target.value;
        this.Tipo= caso.Type;
        this.Descripcion = caso.Description;
        this.Asunto = caso.Subject;
        this.Status = caso.Status;
        this.getCaso(caso.Id);
       
      
        this.template.querySelector(".case_view_modal").show();

        

    }

    getCaso(Case){
        Lista({
            userId:Case
        })
        .then(result =>{
            let CasoData = JSON.parse(JSON.stringify(result));
            this.ListaCasos = CasoData;
           
          })
          .catch(error => {
            this.error = error;

        });      
    }*/


}