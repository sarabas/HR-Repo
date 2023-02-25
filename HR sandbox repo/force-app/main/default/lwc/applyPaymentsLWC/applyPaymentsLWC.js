import { LightningElement, api, track, wire } from "lwc";
import getPaymentsToInvoice from "@salesforce/apex/PaymentsToInvoicesController.getPaymentsToInvoice";
import applyPaymentToInvoice from "@salesforce/apex/PaymentsToInvoicesController.applyPaymentToInvoice";
//import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

const actions = [{ label: "Apply Payment", name: "apply_Payment" }];

export default class ApplyPaymentLWC extends LightningElement {
  @api recordId;
  @api accountId;
  @track sortedBy;
  @track sortedDirection;
  @track invoices;
  @track error;
  amount;
  visible = false;

  @track columns = [
    { label: "Contact", fieldName: "contactName", sortable: true },
    { label: "Invoice Number", fieldName: "invoice", sortable: true },
    {
      label: "Invoice Date",
      fieldName: "invoiceDate",
      type: "date",
      sortable: true
    },
    {
      label: "Outstanding Balance",
      fieldName: "balance",
      type: "currency",
      sortable: true,
      cellAttributes: { alignment: "left" }
    },
    {
      type: "action",
      typeAttributes: { rowActions: actions, menuAlignment: "auto" }
    }
  ];

  @wire(getPaymentsToInvoice, { accID: "$accountId" })
  wiredInvoices({ error, data }) {
    if (data) {
      this.invoices = data;
      //getRecordNotifyChange([{recordId: this.recordId}]);

      this.error = undefined;
    } else if (error) {
      this.invoices = undefined;
      this.error = error;
      console.log("Error " + error.body.message);
    }
  }

  updateColumnSorting(event) {
    this.sortedBy = event.detail.fieldName;
    this.sortedDirection = event.detail.sortDirection;
    this.sortData(this.sortedBy, this.sortedDirection);
  }

  sortData(fieldname, direction) {
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.invoices));

    // Return the value stored in the field
    let keyValue = (a) => {
      return a[fieldname];
    };

    // checking reverse direction
    let isReverse = direction === "desc" ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.invoices = parseData;
  }

  handleAmountChange(event) {
    this.amount = event.detail.value;
  }

  handleRowAction(event) {
    const row = event.detail.row;
    let selectedInvoice = row.invoice;

    let amountCmp = this.template.querySelector(".inputClass");
    let amountValue = amountCmp.value;

    console.log("Selected invoice " + selectedInvoice);
    if (!amountValue) {
      amountCmp.setCustomValidity("You must enter the amount to apply");
      amountCmp.reportValidity();
    } else {
      this.requestApplyPayments(selectedInvoice, this.amount);
    }
  }

  requestApplyPayments(selInvoice, amount) {
    let req = {
      paymentID: this.recordId,
      invoiceNumber: selInvoice,
      applyAmount: amount
    };

    console.log(req);

    applyPaymentToInvoice({ paymentWrapper: req })
      .then(() => {
        this.visible = true;
        console.log("Sent Successfully");
      })
      .then(() => {
        window.location.assign("/" + this.recordId);
      })
      .catch((error) => {
        console.log("Error occured:- " + error.body.message);
      });
  }
}