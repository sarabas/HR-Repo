public without sharing class XMLFeedController
{
    public String output {get; private set;}
    
    // XML feed for Publish = True and Stage = Open
    public void xmlFeed() { 
        List<AVTRRT__Job__c> jobList = [
            SELECT Id, Name, AVTRRT__Job_Title__c,
                AVTRRT__Job_Description_Rich__c, Job_Detail_Page_URL__c, Job_List_Page_URL__c, CreatedDate, AVTRRT__State__c, AVTRRT__Job_City__c, AVTRRT__Job_Category__c, AVTRRT__Job_Description__c, AVTRRT__Recruiter__r.Name, AVTRRT__Job_Application_Tiny_URL__c
            FROM AVTRRT__Job__c
            WHERE (AVTRRT__Publish__c = true
                AND AVTRRT__Stage__c = 'Open')
                ];
        
        System.debug('jobList : ' + jobList);
    
        createXML(jobList);  
    }
  
    private void createXML(List<AVTRRT__Job__c> jobListFinal) {
        XmlStreamWriter w = new XmlStreamWriter();
       // w.writeStartDocument('utf-8','1.0');
        w.writeStartElement(null, 'source', null);
        for (AVTRRT__Job__c job : jobListFinal)
        {
            w.writeStartElement(null, 'job', null);

            if (job.Name != null)
            {
                w.writeStartElement(null, 'name', null);
                w.writeCData(job.Name);
                w.writeEndElement(); // </Name>
            }

            if (job.AVTRRT__Job_Title__c != null)
            {
                w.writeStartElement(null, 'jobtitle', null);
                w.writeCData(job.AVTRRT__Job_Title__c);
                w.writeEndElement(); // </jobtitle>
            }
            
            if (job.CreatedDate != null)
            {
                w.writeStartElement(null, 'CreatedDate', null);
                w.writeCData(String.valueOf(job.CreatedDate));
                w.writeEndElement(); // </jobtitle>
            }
           
            
            if (job.AVTRRT__Job_Description_Rich__c!= null)
            {
                w.writeStartElement(null, 'jobdescription', null);
                w.writeCData(job.AVTRRT__Job_Description_Rich__c);
                w.writeEndElement(); // </jobdescription>
            }
            if (job.Job_Detail_Page_URL__c != null)
            {
                w.writeStartElement(null, 'JobdetailpageURL', null);
                w.writeCData(job.Job_Detail_Page_URL__c);
                w.writeEndElement(); // </jobdescription>
            }
            if (job.Job_List_Page_URL__c != null)
            {
                w.writeStartElement(null, 'JoblistpageURL', null);
                w.writeCData(job.Job_List_Page_URL__c);
                w.writeEndElement(); // </jobdescription>
            }
            if (job.AVTRRT__Job_City__c != null)
            {
                w.writeStartElement(null, 'jobCity', null);
                w.writeCData(job.AVTRRT__Job_City__c);
                w.writeEndElement(); // </jobdescription>
            }
            
           
            if (job.AVTRRT__Recruiter__r.Name != null)
            {
                w.writeStartElement(null, 'recruiter', null);
                w.writeCData(job.AVTRRT__Recruiter__r.Name);
                w.writeEndElement(); // </recruiter>
            } 
            
            if (job.AVTRRT__Job_Application_Tiny_URL__c != null)
            {
                w.writeStartElement(null, 'jobapplicationtinyurl', null);
                w.writeCData(job.AVTRRT__Job_Application_Tiny_URL__c);
                w.writeEndElement(); // </jobapplicationtinyurl>
            }

            w.writeEndElement(); // </job>
        }

        w.writeEndElement(); //</source>

        w.writeEndDocument();
        output = w.getXmlString();
        w.close();   
     
    }
    
}