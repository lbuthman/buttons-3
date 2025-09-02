import {LightningElement, track, api} from 'lwc';
import ZOMBIES from '@salesforce/resourceUrl/maleZombie';

const IMAGES = ['Idle1.png', 'Idle2.png', 'Idle3.png', 'Idle4.png', 'Idle5.png', 'Idle6.png', 'Idle7.png',
'Idle8.png', 'Idle9.png', 'Idle10.png', 'Idle11.png', 'Idle12.png', 'Idle13.png', 'Idle14.png', 'Idle15.png'];

export default class SpriteAnimator extends LightningElement {

    directionFlipper = false;
    internalScore = 100;
    imageIndex = 0;
    @track displayedScore = 0;
    @track zombie = ZOMBIES + '/idle-male-zombie/' + IMAGES[this.imageIndex];

    constructor() {
        super();
        this.animate = this.animate.bind(this);
        this.animate();
    }

    animate(timestamp) {
        const displayedScore = parseInt(this.displayedScore, 10);
        const score = parseInt(this.internalScore, 10);
        this.imageIndex = this.imageIndex === 15 ? 0 : (this.imageIndex + 1);
        this.zombie = ZOMBIES + '/idle-male-zombie/' + IMAGES[this.imageIndex];

        if (displayedScore !== score) {
            if (this.directionFlipper) {
                this.displayedScore = this.displayedScore - 1;
            } else {
                this.displayedScore = this.displayedScore + 1;
            }
            window.requestAnimationFrame(this.animate);
        }
        else {
            this.directionFlipper = !this.directionFlipper;
            this.displayedScore = this.directionFlipper ? this.displayedScore - 1 : this.displayedScore + 1;
            this.internalScore = this.directionFlipper ? 0 : 100;
            window.requestAnimationFrame(this.animate);
        }
    }
}