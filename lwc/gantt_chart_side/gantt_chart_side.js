import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import momentJS from "@salesforce/resourceUrl/momentJS";
import { loadScript } from "lightning/platformResourceLoader";
import getChartData from "@salesforce/apex/ganttSide.getChartData";
import USER_EMAIL from '@salesforce/schema/User.Email';
import {getRecord} from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';



export default class Gantt_chart_side extends LightningElement {
    email;
    error;
    @wire(getRecord, {
        recordId: Id,
        fields: [USER_EMAIL]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data) {
            this.email = data.fields.Email.value;
        }
    }
    @api recordId = "";
    @api objectApiName;
    @track isResourceView;
    @track isProjectView;
    @track isRecordTypeView;
    @api defaultView;
    @track startDateUTC; // sending to backend using time
    @track endDateUTC; // sending to backend using time
    @track formattedStartDate; // Title (Date Range)
    @track formattedEndDate; // Title (Date Range)
    @track dates = []; // Dates (Header)
    @track diasFestivos={};
    dateShift = 7; // determines how many days we shift by
  
    // options
    @track datePickerString; // Date Navigation
    @track view = {
      // View Select
      options: [
        {
          label: "View by Day",
          value: "1,14"
        },
        {
          label: "View by Week",
          value: "7,10"
        },
        {
          label: "View by Month",
          value: "30,6"
        }
      ],
      slotSize: 1,
      slots: 1
    };
      // gantt_chart_resource
  @track startDate;
  @track endDate;
  @track projectId;
  @track resources = [];

  constructor() {
    super();
    this.template.addEventListener("click", this.closeDropdowns.bind(this));
  }

  connectedCallback() {
    Promise.all([
      loadScript(this, momentJS)
    ]).then(() => {

      
      switch (this.defaultView) {
        
        case "View by Day":
          this.setView("1,14");
          break;
        case "View by Week":
          this.setView("7,10");
          break;
        case "View by Month":
          this.setView("30,6");
          break;
        default:
          this.setView("30,6");
      }
      this.setStartDate(new Date());
      this.handleRefresh();
    });
  }
    // catch blur on allocation menus
  closeDropdowns() {
    Array.from(
      this.template.querySelectorAll(".lwc-resource-component")
    ).forEach(row => {
      row.closeAllocationMenu();
    });
  }

  /*** Navigation ***/
  setStartDate(_startDate) {
    if (_startDate instanceof Date && !isNaN(_startDate)) {
      _startDate.setHours(0, 0, 0, 0);

      this.datePickerString = _startDate.toISOString();
      if(this.view.slotSize==30){
        this.startDate = moment(_startDate)
        .date(1)
        .toDate();
      }else{
        this.startDate = moment(_startDate)
        .day(1)
        .toDate();
      }

      
      this.startDateUTC =
        moment(this.startDate)
          .utc()
          .valueOf() -
        moment(this.startDate).utcOffset() * 60 * 1000 +
        "";
      this.formattedStartDate = this.startDate.toLocaleDateString();

      this.setDateHeaders();
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          message: "Invalid Date",
          variant: "error"
        })
      );
    }
  }
  setDateHeaders() {
    if(this.view.slotSize==30){
      this.endDate = moment(this.startDate)
      .add(5, "months")
      .toDate();
    }else{
    this.endDate = moment(this.startDate)
      .add(this.view.slots * this.view.slotSize - 1, "days")
      .toDate();
    }
    this.endDateUTC =
      moment(this.endDate)
        .utc()
        .valueOf() -
      moment(this.endDate).utcOffset() * 60 * 1000 +
      "";
    this.formattedEndDate = this.endDate.toLocaleDateString();

    const dayNames = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    let today = new Date();
    today.setHours(0, 0, 0, 0);
    today = today.getTime();
    let dates = {}; 
    if(this.view.slotSize==30){

      for (let i = 0; i < this.view.slots; i++) { 
      let date = moment(this.startDate).add(i, "months");
      let index = date.format("YYYYMM");
      if (!dates[index]) {
        dates[index] = {
          dayName: '',
          name: date.format("MMMM"),
          days: []
        };
      }

      let day = {
        class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
        label: date.format("D/M"),
        start: date.toDate()
      };

      if (this.view.slotSize > 1) {
        let end = moment(date).add(this.view.slotSize - 1, "days");
        day.end = end.toDate();
      } else {
        day.end = date.toDate();
        day.dayName = date.format("ddd");
        if (date.day() === 0) {
          day.class = day.class + " lwc-is-week-end";
        }
      }

      if (today >= day.start && today <= day.end) {
        day.class += " lwc-is-today";
      }

      dates[index].days.push(day);
      dates[index].style =
        "width: calc(" +
        dates[index].days.length +
        "/" +
        this.view.slots +
        "*100%)";
    }
  }else{

     for (let date = moment(this.startDate); date <= moment(this.endDate); date.add(this.view.slotSize , "days")) {
      let index = date.format("YYYYMM");
      if (!dates[index]) {
        dates[index] = {
          dayName: '',
          name: date.format("MMMM"),
          days: []
        };
      }

      let day = {
        class: "slds-col slds-p-vertical_x-small slds-m-top_x-small lwc-timeline_day",
        label: date.format("D/M"),
        start: date.toDate()
      };

      if (this.view.slotSize > 1) {
        let end = moment(date).add(this.view.slotSize - 1, "days");
        day.end = end.toDate();
      } else {
        day.end = date.toDate();
        day.dayName = date.format("ddd");
        if (date.day() === 0) {
          day.class = day.class + " lwc-is-week-end";
        }
      }

      if (today >= day.start && today <= day.end) {
        day.class += " lwc-is-today";
      }

      dates[index].days.push(day);
      dates[index].style =
        "width: calc(" +
        dates[index].days.length +
        "/" +
        this.view.slots +
        "*100%)";
    }
  }
    // reorder index
    this.dates = Object.values(dates);

    Array.from(
      this.template.querySelectorAll("c-gantt_chart_resource")
    ).forEach(resource => {
      resource.refreshDates(this.startDate, this.endDate, this.view.slotSize);
    });  
   }
  navigateToToday() {
    this.setStartDate(new Date());
    this.handleRefresh();
  }
  navigateToPrevious() {
    let _startDate = new Date(this.startDate);
    if(this.view.slotSize==30){
      _startDate.setMonth(_startDate.getMonth()-1);
    }else{
    _startDate.setDate(_startDate.getDate() - this.dateShift);
    }
    this.setStartDate(_startDate);
    this.handleRefresh();
  }

  navigateToNext() {
    let _startDate = new Date(this.startDate);
    if(this.view.slotSize==30){
      _startDate.setMonth(_startDate.getMonth()+1);
    }else{
    _startDate.setDate(_startDate.getDate() + this.dateShift);
    }
    this.setStartDate(_startDate);
    this.handleRefresh();
  }

  navigateToDay(event) {
    this.setStartDate(new Date(event.target.value + "T00:00:00"));
    this.handleRefresh();
  }

  setView(value) {
    let values = value.split(",");
    this.view.value = value;
    this.view.slotSize = parseInt(values[0], 10);
    this.view.slots = parseInt(values[1], 10);
  }

  handleViewChange(event) {
    this.setView(event.target.value);
    this.setDateHeaders();
    this.handleRefresh();
  }
  /*** /Navigation ***/
    // catch blur on allocation menus
  closeDropdowns() {
    Array.from(
      this.template.querySelectorAll(".lwc-resource-component")
    ).forEach(row => {
      row.closeAllocationMenu();
    });
  }

  
  handleRefresh() {
    // refreshApex(this.wiredData);
    let self = this;
    self.resources.length = 0;

    getChartData({
        recordId: self.recordId ? self.recordId : '',
        startTime: self.startDateUTC,
        endTime: self.endDateUTC,
        slotSize: self.view.slotSize,
        userId: Id
    }).then(data => {
        self.projectId = data.projectId;
        self.projects = data.projects;
        self.roles = data.roles;

        // empty old data
        // we want to keep resources we've already seen
        self.resources.forEach(function (resource, i) {
            self.resources[i] = {
                Id: resource.Id,
                Name: resource.Name,
                Rol__c: resource.Rol__c,
                allocationsByProject: {}
            };
        });

        data.resources.forEach(function (newResource) {
            for (let i = 0; i < self.resources.length; i++) {
                if (self.resources[i].Id === newResource.Id) {
                    self.resources[i] = newResource;
                    return;
                }
            }

            self.resources.push(newResource);
        });

        debugger;
    }).catch(error => {
        this.dispatchEvent(new ShowToastEvent({
            message: error.body.message,
            variant: 'error'
        }));
    });
  }

}