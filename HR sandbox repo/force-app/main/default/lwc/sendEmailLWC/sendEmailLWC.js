import { LightningElement, api, track } from "lwc";
import sendSingleEmailLWC from "@salesforce/apex/SendSingleVFEmail.sendSingleEmailLWC";
import getInvoiceDetails from "@salesforce/apex/GetInvoiceDetails.getInvoiceDetails";

export default class SendEmailLWC extends LightningElement {
  @api flexipageRegionWidth = "LARGE";
  @api recordId;
  @track error;
  @track hasRendered = true;


  invoiceNum = "";
  invoicedate="";

  contactName = "";
  toEmail;
  subject = "";
  body = "";
  additionalTo = "";
  CC = "";
  visible = false;
  

  renderedCallback() {
    if (this.hasRendered) {
      console.log("The Id is " + this.recordId);
      this.hasRendered = false;

      getInvoiceDetails({ accID: this.recordId })
        .then((result) => {
          console.log("Results are " + JSON.stringify(result));

          this.toEmail = result.Email;
          this.invoiceNum = result.Invoice;
          this.contactName = result.Contact;

          this.subject =
            "Mom Relaunch : " + this.contactName + " this month Invoice  " + this.invoiceNum;
          
            this.body=
             "Hello  "   + this.contactName  +" ,\nPlease find the attached invoice " +this.invoiceNum +" for Mom Relaunch membership. \n For any additional information, please reach out via email:mraccounting@momrelaunch.com. \nPlease include candidate's name while making payment.\nThankyou.";
            
             
          //this.body = 'Please find the attached invoice. \n';
          
  
    
          this.error = undefined;

          console.log("Email " + this.toEmail);
          console.log("Contact " + this.contactName);
          console.log("Invoice Number " + this.invoiceNum);
          
        })
        .catch((err) => {
          console.log("Error occured " + err.body.message);
          this.error = err;
        });
    }
  }
  handleClick() {
    const editor = this.template.querySelector("lightning-input-rich-text");
    editor.setRangeText("");
  }
  handleToChange(event) {
    this.toEmail = event.target.value;
  }

  handleAdditionalToChange(event) {
    this.additionalTo = event.target.value;
  }

  handleCCChange(event) {
    this.CC = event.target.value;
  }
  handleSubjectChange(event) {
    this.subject = event.target.value;
  }

  handleBodyChange(event) {
    this.body = event.target.value;
  }

  handleSend() {
    let parameterObject = {
      contEmail: this.toEmail,
      contactName: this.contactName,
      addTo: this.additionalTo,
      acc: this.recordId,
      ccEmail: this.CC,
      subject: this.subject,
      body: this.body
    };

    sendSingleEmailLWC({ params: parameterObject })
      .then((result) => {
        console.log('Outgoing parameter object is '+ JSON.stringify(parameterObject));
        console.log("Result is " + JSON.stringify(result));
        this.visible = true;
        // let delay = 1000
        //     setTimeout(() => {
        //         this.visible = false;
        //     }, delay );
      })
      .then(() => {
        const inputFields = this.template.querySelectorAll(".inputClass");
        if (inputFields) {
          inputFields.forEach((field) => {
            field.value = null;
          });
          const selectElement = this.template.querySelector(
            "lightning-input-rich-text"
          );
          selectElement.value = "";
        }
      })

      .then(() => {
        console.log("Success!");
        window.location.assign("/" + this.recordId);
      })
      .catch((err) => {
        this.error = err;
        console.log("Error occured " + err.body.message);
        //console.log("Error occured ");
      });
  }

  handleCancel() {
    window.location.assign("/" + this.recordId);
  }
}