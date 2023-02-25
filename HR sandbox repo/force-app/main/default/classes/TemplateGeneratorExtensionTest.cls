@isTest
public class TemplateGeneratorExtensionTest {
    static Account accSoDoc, accPoDoc;
    static Contact conObj;
    static AVAB__SO_Document__c soDoc;
    static AVAB__Transaction_Line_Items__c tliAR, tliAR1, tliAR2, tliAR3;
    static TMS__Time__c tim2, tim3, tim4;
    static TMS__Week_Management__c weekMgmt;
    static TMS__Timesheet__c timeSheet;
    static TMS__Task__c tskObj, tskObj1, tskObj2;
    static RecordType rectype, invoiceRT, custRecType;

    static testMethod void TemplateGeneratorExtensionTest() {
        List<RecordType> recs;
        recs = [select id from RecordType where Name =:'Invoice'];
        List<SObject> sObjList = new List<SObject>();
        invoiceRT = recs == null || recs.size()==0?
                        new RecordType(Name='Invoice')
                        :recs.get(0);
        
        recs = [select id, Name from RecordType where Name ='Customer' AND SobjectType='Account'];
        custRecType = recs == null || recs.size()==0?
                        new RecordType(Name='Customer', SobjectType='Account')
                        :recs.get(0);

        accSoDoc = new Account(Name ='TestCustomerAcc',RecordTypeId=custRecType.Id, BillingCity = 'TestCity');
        //insert accSoDoc;
        sObjList.add(accSoDoc);
        conObj = new Contact(FirstName = 'Subhani', LastName = 'Last');
        sObjList.add(conObj);
        TMS__Project_Resource__c projRes = new TMS__Project_Resource__c();
        projRes.TMS__Contact__c = conObj.Id;
        insert projRes;
        
        tskObj = new TMS__Task__c(Name = 'Regular Hours', TMS__Project_Resource__c = projRes.Id);
        //insert tskObj;
        sObjList.add(tskObj);
        tskObj1 = new TMS__Task__c(Name = 'OT Hours', TMS__Project_Resource__c = projRes.Id);
       // insert tskObj1;
       sObjList.add(tskObj1);
        tskObj2 = new TMS__Task__c(Name = 'Holiday Hours', TMS__Project_Resource__c = projRes.Id);
        //insert tskObj2;
        sObjList.add(tskObj2);
        
        weekMgmt = new TMS__Week_Management__c(TMS__Start_Date__c = Date.newInstance(2015 , 04 ,05),
                                                 TMS__End_Date__c = Date.newInstance(2015 , 04 ,12), TMS__Active__c = true);
        insert weekMgmt;
        //sObjList.add(weekMgmt);
       
        
        AVAB__Accounting_Settings__c accountSettings=new AVAB__Accounting_Settings__c(AVAB__Default_Revenue_Account__c='TestFinance', AVAB__Default_Revenue_Account_For_AP__c='TestFinance');
        //insert accountSettings; 
        sObjList.add(accountSettings);
        
        AVAB__GL_Account__c glAccount= new AVAB__GL_Account__c(AVAB__Account_Type__c='Expense',Name='TestFinance');
        //insert glAccount;
        sObjList.add(glAccount);
        
        insert sObjList;
        
        timeSheet = new TMS__Timesheet__c(TMS__Week_Management__c = weekMgmt.Id);
        insert timeSheet;
        
        
        soDoc = new AVAB__SO_Document__c(AVAB__Status__c='Post',
                                                                RecordTypeId = invoicert.Id, AVAB__Date__c = Date.newInstance(2015 , 04 ,10),
                                                                AVAB__Due_Date__c = Date.newInstance(2015 , 04 ,10), AVAB__Billing_Address_1__c = 'PO Box-1234',
                                                               AVAB__Billing_City__c = 'San Francisco', AVAB__Billing_Country__c = 'US', AVAB__Billing_State__c = 'California', AVAB__Billing_Zip__c = '94101',AVAB__Shipping_Address_1__c = 'PO Box-1234',
                                                                AVAB__Shipping_City__c = 'San Francisco', AVAB__Shipping_Country__c = 'US',
                                                                AVAB__Shipping_State__c = 'California',AVAB__Shipping_Zip__c = '94101',AVAB__Account__c=accSoDoc.Id);
        insert soDoc;
        //sObjList.add(soDoc);

        
        //sObjList.add(glAccount);
        

        AVAB__Item__c item=new AVAB__Item__c(AVAB__Tax__c='Taxable',AVAB__Sales_Price__c=45,Name='TestProduct',
            AVAB__Income_Account__c = glAccount.id);
        insert item;
        
         List<SObject> sObjListObjLineItems = new List<SObject>(); 

        tliAR = new AVAB__Transaction_Line_Items__c(AVAB__AR_Transaction__c=soDoc.Id, 
                        AVAB__Product__c=item.Id,AVAB__Quantity__c=2,AVAB__Sales_Price__c=1495,
                        ABTS__Task__c = tskObj.Id);
        //insert tliAR;
        sObjListObjLineItems.add(tliAR);
        
        tliAR1 = new AVAB__Transaction_Line_Items__c(AVAB__AR_Transaction__c=soDoc.Id, 
                        AVAB__Product__c=item.Id,AVAB__Quantity__c=2,AVAB__Sales_Price__c=1495,
                        ABTS__Task__c = tskObj1.Id);
        //insert tliAR1;
        sObjListObjLineItems.add(tliAR1);
        
        tliAR2 = new AVAB__Transaction_Line_Items__c(AVAB__AR_Transaction__c=soDoc.Id, 
                        AVAB__Product__c=item.Id,AVAB__Quantity__c=2,AVAB__Sales_Price__c=1495,
                        ABTS__Task__c = tskObj2.Id);
        //insert tliAR2;
        sObjListObjLineItems.add(tliAR2);
        
        tliAR3 = new AVAB__Transaction_Line_Items__c(AVAB__AR_Transaction__c=soDoc.Id,
                         AVAB__Product__c=item.Id,AVAB__Quantity__c=2,AVAB__Sales_Price__c=1495
                         );
        //insert tliAR3;
        sObjListObjLineItems.add(tliAR3);
        
        insert sObjListObjLineItems;
        
        List<SObject> sObjListObj = new List<SObject>();
        /*
        tim2 = new TMS__Time__c(TMS__Invoice_Line_Item__c=tliAR.Id, TMS__Time_Spent__c = 5.00,
                                TMS__Date__c = Date.newInstance(2015 , 04 ,07));
        insert tim2;*/
        //sObjListObj.add(tim2);
        
        tim3 = new TMS__Time__c(TMS__Time_Spent__c = 15.00,
                                TMS__Date__c = Date.newInstance(2015 , 04 ,08),
                                TMS__Week_Management__c = weekMgmt.Id);
        insert tim3;
        tim3.ABTS__Invoice_Line_Item__c=tliAR1.Id;
        update tim3;
        //sObjListObj.add(tim3);
        
        
        insert sObjListObj;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(soDoc);
        TemplateGeneratorExtensionCustom tge = new TemplateGeneratorExtensionCustom(sc);
        tge.gettlItems1();
    }
        
        

    }