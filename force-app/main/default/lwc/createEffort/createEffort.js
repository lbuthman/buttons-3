import {LightningElement, track, api} from 'lwc';
import createEffort from '@salesforce/apex/EffortService.createEffort';
import endEffort from '@salesforce/apex/EffortService.endEffort';

export default class CreateEffort extends LightningElement {

    @api recordId;

    @track effortRecord;
    @track context;
    @track tempNotes;
    @track effortCompleted = false;

    startTime;

    connectedCallback() {
        this.initialize();
    }

    initialize() {
        this.effortCompleted = false;
        this.startTime = new Date();

        setTimeout(() => {
            this.createNewEffortRecord();
            this.template.querySelector("lightning-input[data-id=context]").focus();
        }, 300);
    }

    handleContextInput(event) {
        this.context = event.detail.value;
    }

    handleTempNoteInput(event) {
        this.tempNotes = event.detail.value;
    }

    createNewEffortRecord() {
        createEffort({challengeId: this.recordId})
            .then(value => {
                this.effortRecord = value;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            })
    }

    handleEndEffort() {
        this.effortCompleted = true;
        this.completeEffortRecord();
    }

    completeEffortRecord() {
        const payload = {
            recordId: this.effortRecord.Id,
            context: this.context,
            tempNotes: this.tempNotes
        };

        endEffort({effortDataString: JSON.stringify(payload)})
            .then(value => {
                console.log('end effort successful?');
                console.log(value);
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }
}