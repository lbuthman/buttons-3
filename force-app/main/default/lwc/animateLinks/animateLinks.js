import {LightningElement} from 'lwc';

export default class AnimateLinks extends LightningElement {

    renderedCallback() {
        this.refs.test.classList.add('uncoolor');
    }

    toggleBackground() {
        this.refs.test.classList.toggle('coolor');
        this.refs.test.classList.toggle('uncoolor');
    }
}