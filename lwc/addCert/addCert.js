import { LightningElement, track } from 'lwc';
import saveCert from "@salesforce/apex/ganttChart.guardarCertificacion";
import userId from '@salesforce/user/Id';

export default class AddCert extends LightningElement {
@track CertificationOptions = [
    {
      label:'Salesforce',
      value:'Salesforce'
    },
    {
      label:'Mulesoft',
      value:'Mulesoft'
    },
    {
      label:'Partner Salesforce',
      value:'Partner Salesforce'
    },
    {
      label:'Otras',
      value:'Otras'
    }
  ];
  @track Certifications=[];
  typeT;
  typeC;
  fileData;
  otras = '';
  disab = true;
  disO = true;
  
  setTypeT(event){
  this.typeT = event.currentTarget.value;
  if(this.typeT == 'Salesforce'){
    this.disO = true;
    this.otras = '';
    this.Certifications = [
      {
        label:'Salesforce Certified Administrator',
        value:'Salesforce Certified Administrator'
      },
      {
        label:'Salesforce Certified Advanced Administrator',
        value:'Salesforce Certified Advanced Administrator'
      },
      {
        label:'Platform App Builder',
        value:'Platform App Builder'
      },
      {
        label:'User Experience Designer',
        value:'User Experience Designer'
      },
      {
        label:'Sales Cloud Consultant',
        value:'Sales Cloud Consultant'
      },
      {
        label:'CPQ Specialist',
        value:'CPQ Specialist'
      },
      {
        label:'Service Cloud Consultant',
        value:'Service Cloud Consultant'
      },
      {
        label:'Field Service Lightning Consultant',
        value:'Field Service Lightning Consultant'
      },
      {
        label:'Community Cloud Consultant',
        value:'Community Cloud Consultant'
      },
      {
        label:'Einstein Analytics and Discovery Consultant',
        value:'Einstein Analytics and Discovery Consultant'
      },
      {
        label:'Nonprofit Cloud Consultant',
        value:'Nonprofit Cloud Consultant'
      },
      {
        label:'Education Cloud Consultant',
        value:'Education Cloud Consultant'
      },
      {
        label:'OmniStudio Consultant',
        value:'OmniStudio Consultant'
      },
      {
        label:'Platform Developer I',
        value:'Platform Developer I'
      },
      {
        label:'Platform Developer II',
        value:'Platform Developer II'
      },
      {
        label:'JavaScript Developer I',
        value:'JavaScript Developer I'
      },
      {
        label:'Industries CPQ Developer',
        value:'Industries CPQ Developer'
      },
      {
        label:'OmniStudio Developer',
        value:'OmniStudio Developer'
      },
      {
        label:'B2C Commerce Developer',
        value:'B2C Commerce Developer'
      },
      {
        label:'B2C Commerce Architect',
        value:'B2C Commerce Architect'
      },
      {
        label:'Salesforce Accredited B2B Commerce Administrator',
        value:'Salesforce Accredited B2B Commerce Administrator'
      },
      {
        label:'Salesforce Accredited B2B Commerce Developer',
        value:'Salesforce Accredited B2B Commerce Developer'
      },
      {
        label:'Salesforce Data Architecture and Management Designer',
        value:'Salesforce Data Architecture and Management Designer'
      },
      {
        label:'Salesforce Sharing and Visibility Designer',
        value:'Salesforce Sharing and Visibility Designer'
      },
      {
        label:'Salesforce Identity and Access Management Designer',
        value:'Salesforce Identity and Access Management Designer'
      },
      {
        label:'Integration Architecture Designer',
        value:'Integration Architecture Designer'
      },
      {
        label:'Development Lifecycle and Deployment Designer',
        value:'Development Lifecycle and Deployment Designer'
      },
      {
        label:'Heroku Architecture Designer',
        value:'Heroku Architecture Designer'
      },
      {
        label:'Application Architect',
        value:'Application Architect'
      },
      {
        label:'System Architect',
        value:'System Architect'
      },
      {
        label:'B2C Solution Architect',
        value:'B2C Solution Architect'
      },
      {
        label:'Certified Technical Architect',
        value:'Certified Technical Architect'
      },
      {
        label:'Pardot Specialist',
        value:'Pardot Specialist'
      },
      {
        label:'Pardot Consultant',
        value:'Pardot Consultant'
      },
      {
        label:'Marketing Cloud Admin',
        value:'Marketing Cloud Admin'
      },
      {
        label:'Marketing Cloud Email Specialist',
        value:'Marketing Cloud Email Specialist'
      },
      {
        label:'Marketing Cloud Consultant',
        value:'Marketing Cloud Consultant'
      },
      {
        label:'Marketing Cloud Developer',
        value:'Marketing Cloud Developer'
      },
      {
        label:'Datorama Solution Architect',
        value:'Datorama Solution Architect'
      }

    ];
  }else if (this.typeT == 'Mulesoft'){
    this.otras = '';
    this.disO = true;
    this.Certifications = [
      {
        label:'Certified Developer Level 1 (Mule 4)',
        value:'Certified Developer Level 1 (Mule 4)'
      },
      {
        label:'Certified Developer Level 1 (Mule 4) DELTA',
        value:'Certified Developer Level 1 (Mule 4) DELTA'
      },
      {
        label:'Certified Developer Integration and API Associate (Mule 3)',
        value:'Certified Developer Integration and API Associate (Mule 3)'
      },
      {
        label:'Certified Developer Integration Professional (Mule 3)',
        value:'Certified Developer Integration Professional (Mule 3)'
      },
      {
        label:'Certified Developer API Design Associate (RAML 1.0)',
        value:'Certified Developer API Design Associate (RAML 1.0)'
      }
    ];
  }else if (this.typeT == 'Partner Salesforce' ||this.typeT == 'Otras'){
    this.disO = false;
    this.Certifications = [
      {
        label:'Otras',
        value:'Otras'
      }
    ];
  }

  this.disab = false;

  }
  setTypeC(event){
  this.typeC = event.currentTarget.value;
  }
  fileput(event){
    const file = event.target.files[0];
    var reader = new FileReader();
    reader.onload = () => {
      var base64 = reader.result.split(',')[1]
      this.fileData = {
          'filename': file.name,
          'base64': base64
      }
      console.log(this.fileData)
  }
  reader.readAsDataURL(file)

  }
  saveCert(){
    const {base64, filename} = this.fileData
    saveCert({
        Id: userId,
        Tipo:this.typeT,
        Certif:this.typeC,
        otra:this.otras,
        base64:base64,
        filename:filename
      });

      this.template.querySelector(".create-certif").hide();
  }
  otracert(otra){
    this.otras = otra.currentTarget.value;
    
  }

  openCertificationModal() {
    this.template.querySelector(".create-certif").show();
  }

}