import {LightningElement} from 'lwc';

export default class ExperienceLogger extends LightningElement {

    experiencePoints = 1;

    increment() {
        if (this.experiencePoints >= 99) {
            this.experiencePoints = 99;
        }
        else {
            this.experiencePoints += 1;
        }
    }

    decrement() {
        if (this.experiencePoints <= 1) {
            this.experiencePoints = 1;
        }
        else {
            this.experiencePoints -= 1;
        }
    }

    handleInput(event) {
        const input = Number(event.detail.value);

        if (input > 0) {
            this.experiencePoints = input;
        }
    }
}