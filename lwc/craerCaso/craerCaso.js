import { LightningElement , track} from 'lwc';
import userId from '@salesforce/user/Id';
import guardarCaso from '@salesforce/apex/guardarCaso.guardarCaso'

export default class AddVacaciones extends LightningElement {

   
  @track opcionesTipoCaso = [
    
    {
      label:'Abonar gastos',
      value:'Abonar gastos'
    },
    {
      label:'Solicitar voucher',
      value:'Solicitar voucher'
    },
    
  ];
  type='';
  setType(event){
    this.type = event.currentTarget.value;
  }
  
    
  openAddCaso() {
      this.template.querySelector(".create-caso-modal").show();
    }

    texto='';

    onChangeTexto(event){

        this.texto=event.currentTarget.value;

    }

    textArea='';

    onChangeTextArea(event){

        this.textArea=event.currentTarget.value;

    }

    saveCase(event){

        guardarCaso({

            userId:userId,
            Tipo:this.type,
            Asunto:this.texto,
            descripcion:this.textArea,
          

        });

        this.template.querySelector(".create-caso-modal").hide();
    }
}