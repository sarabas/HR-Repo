global with sharing class TemplateGeneratorExtensionCustom {
  global AVAB__SO_Document__c sod;
  global List<wrapperEmp> wrapperEmpList { get; set; }
  global List<AVAB__Transaction_Line_Items__c> tlItems { get; set; }
  global Id weekManagementId;
  global Decimal salesTax { get; set; }
  global AVAB__SO_Document__c soDoc { get; set; }

  global TemplateGeneratorExtensionCustom(
    ApexPages.StandardController controller
  ) {
    this.sod = (AVAB__SO_Document__c) controller.getRecord();
    Apexpages.currentPage()
      .getHeaders()
      .put(
        'content-disposition',
        'inline; filename=Invoice_' +
        sod.Name +
        '.pdf'
      );
    gettlItems1();
    salesTax = 0.00;
  }

  global List<wrapperEmp> gettlItems1() {
    wrapperEmpList = new List<wrapperEmp>();

    tlItems = [
      SELECT
        Id,
        AVAB__Quantity__c,
        AVAB__Product__r.Name,
        AVAB__Product_Description__c,
        Dynamic_Product_Description__c,
        AVAB__Total_Sales_Price__c,
        AVAB__Sales_Price__c,
        (
          SELECT
            Id,
            TMS__Resource__c,
            TMS__Start_Time__c,
            TMS__Date__c,
            TMS__Task__r.Name,
            TMS__End_Time__c,
            TMS__Time_Spent__c,
            TMS__Time_Spent_Time_Format__c,
            TMS__Bill_Rate__c,
            TMS__Time_Spent_Formula__c,
            TMS__Week_Management__c
          FROM ABTS__Time__r
        )
      FROM AVAB__Transaction_Line_Items__c
      WHERE AVAB__AR_Transaction__c = :sod.Id
    ];
    System.debug('>>>tlItems' + tlItems);

    soDoc = [
      SELECT Id, AVAB__Amount__c, AVAB__Tax_Rate__c, AVAB__Payments_Received__c
      FROM AVAB__SO_Document__c
      WHERE Id = :sod.Id
    ];

    salesTax = soDoc.AVAB__Amount__c * soDoc.AVAB__Tax_Rate__c / 100;

    for (AVAB__Transaction_Line_Items__c tlitem : tlItems) {
      System.debug('tlitem ' + tlitem);
      wrapperEmp obj = new wrapperEmp();
      List<TMS__Time__c> timesInvoice = tlitem.ABTS__Time__r;

      if (!timesInvoice.isEmpty()) {
        System.debug('timesInvoice ' + timesInvoice);
        obj.name = timesInvoice.get(0).TMS__Resource__c;
        System.debug('>>>obj.name' + obj.name);
        obj.prodName = tlitem.AVAB__Product__r.Name;
        obj.quantity = tlitem.AVAB__Quantity__c;
        obj.taskName = timesInvoice.get(0).TMS__Task__r.Name;
        obj.salesPrice = tlitem.AVAB__Sales_Price__c;
        obj.total = tlitem.AVAB__Total_Sales_Price__c;
        //weekManagementId = timesInvoice.get(0).TMS__Week_Management__c;
        //System.debug('>>>weekManagementId' + weekManagementId);

        // TMS__Week_Management__c weekM;
        // weekM = [
        //   SELECT Id, WeekCustom__c
        //   FROM TMS__Week_Management__c
        //   WHERE Id = :weekManagementId
        // ];
        //System.debug('weekM : ' + weekM);
        //obj.weekRange = weekM.WeekCustom__c;
      }
      wrapperEmpList.add(obj);
    }

    System.debug('>>>>wrapperEmpList' + wrapperEmpList);
    return wrapperEmpList;
  }

  global class wrapperEmp {
    global String name { get; set; }
    global String weekRange { get; set; }
    global String prodName { get; set; }
    global Decimal salesPrice { get; set; }
    global Decimal quantity { get; set; }
    global Decimal total { get; set; }
    global String taskName { get; set; }
  }
}