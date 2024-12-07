
public class ResumeGeneratorController {
    @AuraEnabled
    public static void generateResume(String candidateId){
        try {
            Candiate__c candidate = [SELECT Id, 
                                            Name, 
                                            Email__c, 
                                            Mobile__c, 
                                            Work_Experience__c, 
                                            Education__c, 
                                            Skills_And_Certifications__c 
                                      FROM Candiate__c 
                                      WHERE Id = :candidateId];
            
            PageReference pdfPage = Page.Candidate_Resume; // Replace with your Visualforce page name
            pdfPage.getParameters().put('id', candidate.Id);
            Blob pdfBlob = pdfPage.getContentAsPDF();
            
            Attachment resumeAttachment = new Attachment();
            resumeAttachment.Name = candidate.Name + '_Resume.pdf';
            resumeAttachment.Body = pdfBlob;
            resumeAttachment.ParentId = candidate.Id;
            resumeAttachment.ContentType = 'application/pdf';
            insert resumeAttachment;
        } catch (Exception e) {
            System.debug('Error in resume generation: ' + e.getMessage());
            throw new AuraHandledException('Resume generation failed. ' + e.getMessage());
        }
    }
}
