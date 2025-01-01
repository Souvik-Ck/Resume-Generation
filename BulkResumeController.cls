/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class BulkResumeController {
    public Boolean isGenerated { get; set; }
    public List<Id> selectedCandidateIds { get; set; }

    public BulkResumeController() {
        isGenerated = false;
        selectedCandidateIds = new List<Id>();
        // Populate selectedCandidateIds based on your implementation
        // This could be through URL parameters, form inputs, etc.
    }

    public PageReference generateBulkResumes() {
        if (selectedCandidateIds.isEmpty()) {
            // Handle the case where no candidates are selected
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No candidates selected.'));
            return null;
        }

        // Enqueue the queueable job with the selected candidate IDs
        System.enqueueJob(new GenerateCandidateResumesQueueable(selectedCandidateIds));

        isGenerated = true;
        return null;
    }
}
