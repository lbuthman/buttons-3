import {LightningElement, api, track} from 'lwc';
import {CloseActionScreenEvent} from "lightning/actions";
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getUnderstandingsByGoal from '@salesforce/apex/UnderstandingReviewerService.getUnderstandingsByResource';
import markUnderstandingsAsReviewed from '@salesforce/apex/UnderstandingReviewerService.markUnderstandingsAsReviewed';

export default class ReviewUnderstandings extends LightningElement {

    @api recordId;

    understandings = [];
    @track currentUnderstanding;
    totalReviewed = 0;
    totalNotReviewed = 0;

    currentIndex = 0;
    @track noMoreToReview = false;
    reviewedUnderstandings = [];

    connectedCallback() {
        this.initialize();
    }

    initialize() {
        setTimeout(() => {
            this.getUnderstandings();
        }, 300);
    }

    getUnderstandings() {
        getUnderstandingsByGoal({goalId: this.recordId})
            .then(response => {
                this.understandings = response.understandings;
                this.currentUnderstanding = this.understandings[this.currentIndex];
                this.totalReviewed = response.totalReviewed;
                this.totalNotReviewed = response.totalNotReviewed;
            })
            .catch(error => {
                console.log('---error encountered---');
                console.log(JSON.stringify(error));
            })
    }

    advanceToNextUnderstanding() {
        this.currentIndex += 1;
        if (this.understandings.length - 1 === this.currentIndex) {
            this.noMoreToReview = true;
        }
        else {
            this.currentUnderstanding = this.understandings[this.currentIndex];
        }
        // this.template.querySelector("lighting-card").click();
    }

    moveUnderstandingToReviewedAndAdvance() {
        this.totalReviewed += 1;
        this.reviewedUnderstandings.push(this.currentUnderstanding);
        this.advanceToNextUnderstanding();
    }

    markReviewed() {
        this.sendAlert("Job In Progress", "beep bop boop", "info");
        markUnderstandingsAsReviewed({understandings: JSON.stringify(this.reviewedUnderstandings)})
            .then(response => {
                this.sendAlert("Job Completed", "Success!",  "success");
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.log('error encountered');
                console.log(JSON.stringify(error));
            });
    }

    sendAlert(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        }));
    }
}