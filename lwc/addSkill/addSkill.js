import { LightningElement, wire,api,track} from 'lwc';
import{refreshApex} from '@salesforce/apex';
import saveSkill from'@salesforce/apex/addSkill.saveSkill';
import searchSkill from'@salesforce/apex/addSkill.searchSkill';
import selectedSk from '@salesforce/apex/addSkill.selectedSk';
import {CloseActionScreenEvent} from 'lightning/actions';

const COLS =[
    {label:'Nombre',fieldName:'Name',type:'text'},
    {label:'Area de Skill',fieldName:'Area_de_Skill__c',type:'text'},
    {label:'Tipo de Skill',fieldName:'Tipo_de_Skill__c',type:'text'},
    {label:'Nivel de Skill',fieldName:'Nivel_de_Skill__c',type:'text'}
];
export default class AddSkill extends LightningElement {
    @api recordId;
    cols = COLS;
    data =[];
    selection = [];
    searchTerm = '';
    error; 
   /* @wire(searchSkill,{searchTerm: '$searchTerm'})
    wiredRecorkds({error,data}){
        if(data){
            this.data =data;
            this.preselected = ['a081X000004GRvyQAG'];
        }else if(error){
            this.data = undefined;
            this.error = error;
        }
    }*/
    connectedCallback(){
        this.getSkill('');
    }
    saveRecord(){        
        saveSkill({idregistro :this.recordId , skillList : this.selection})     
         .then(result =>{        
            return refreshApex(this.data);     
         })     
         .catch(error=>{
            alert('Have error to save ' + JSON.stringify(error));    
        }); 
        eval("$A.get('e.force:refreshView').fire();");
        this.dispatchEvent(new CloseActionScreenEvent());

    }
    getid(evt){
        let updatedItemsSet = new Set();
        let selectedItemsSet = new Set(this.selection);
        let loadedItemsSet = new Set();
        this.data.map((event) => {
            loadedItemsSet.add(event.Id);
        });
        if (evt.detail.selectedRows) {
            evt.detail.selectedRows.map((event) => {
                updatedItemsSet.add(event.Id);
            });
            // Add any new items to the selection list
            updatedItemsSet.forEach((id) => {
            if (!selectedItemsSet.has(id)) {
                selectedItemsSet.add(id);
            }
        });
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selection = [...selectedItemsSet];        
    }
    }
    handleSearchTermChange(event){
        window.clearTimeout(this.delayTimeout);
        const searchTerm = event.target.value;
        this.getSkill(searchTerm);
        this.delayTimeout = setTimeout(() => {
			this.searchTerm = searchTerm;
		}, 300);
    }
    getSkill(searchTerm){
        searchSkill({
            searchTerm:searchTerm
        })
        .then(result =>{
            let skillData = JSON.parse(JSON.stringify(result));
            this.data = skillData;
            this.template.querySelector(
                '[data-id="datarow"]'
              ).selectedRows = this.selection;
          })
          .catch(error => {
            this.error = error;

        });      
    }

}