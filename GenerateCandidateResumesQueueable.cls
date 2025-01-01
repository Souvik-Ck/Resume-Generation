/**
* @description: Queueable class to generate resumes for a list of candidates and attach them as PDFs.
*/
public class GenerateCandidateResumesQueueable implements Queueable {
    private List<Id> candidateIdsList;

    /**
     * @description : Constructor to initialize the class with a list of candidate IDs.
     * @param candidateIdsList : List of candidate IDs for which resumes need to be generated.
     */
    public GenerateCandidateResumesQueueable(List<Id> candidateIdsList) {
        this.candidateIdsList = candidateIdsList;
    }

    /**
     * @description : Executes the queueable job, generates resumes for each candidate, 
     *               and attaches them to the respective Candidate record.
     * @param context: Context of the Queueable execution.
     */
    public void execute(QueueableContext context) {
        List<Attachment> attachmentsToInsert = new List<Attachment>();

        // Query all candidates in one SOQL query to avoid SOQL inside loop
        List<Candiate__c> candidatesList = [
            SELECT Id, Name, Email__c, Phone__c, Skills_And_Certifications__c, 
                   Age__c, City__c, Country__c, Current_Employer__c, 
                   Current_Emplyed__c, Date_Of_Birth__c, Education__c, 
                   Mobile__c, State__c, Street__c, Year_of_Experience__c, 
                   Zip_Postal_Code__c
            FROM Candiate__c
            WHERE Id IN :candidateIdsList
        ];

        for (Candiate__c candidate : candidatesList) {
            try {
                // Generate the PDF by calling the Visualforce page
                PageReference vfPage = Page.CandidateResume;
                vfPage.getParameters().put('id', candidate.Id); // Pass the candidateId
                Blob pdfBlob = vfPage.getContentAsPDF(); // Generate the PDF

                // Create an attachment for the Candidate record
                Attachment attachment = new Attachment(
                    ParentId = candidate.Id,
                    Name = candidate.Name + '_Resume.pdf',
                    Body = pdfBlob,
                    ContentType = 'application/pdf'
                );

                // Add the attachment to the list
                attachmentsToInsert.add(attachment);
            } catch (Exception exp) {
                System.debug('Error generating resume for Candidate ' + candidate.Id + ': ' + exp.getMessage());
            }
        }

        // Insert all attachments at once if any were created
        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
        }
    }
}
