import { LightningElement } from 'lwc';

const FINISH_LINE = 285;

export default class LwcTurtleRacingGame extends LightningElement {
    turtles = [
        { id: 1, position: 0, rank: null, isWinner: false, computedClass: 'result-entry', style: 'transform: translateX(0px);' },
        { id: 2, position: 0, rank: null, isWinner: false, computedClass: 'result-entry', style: 'transform: translateX(0px);' },
        { id: 3, position: 0, rank: null, isWinner: false, computedClass: 'result-entry', style: 'transform: translateX(0px);' }
    ];
    finishOrder = [];
    isRaceOn = false;

    get raceFinished() {
        return this.finishOrder.length === this.turtles.length;
    }

    startRace() {
        this.isRaceOn = true;
        this.finishOrder = [];
        // Reset turtles for the race
        this.resetTurtlesForRace(true);
        this.turtles.forEach(turtle => this.moveTurtle(turtle));
    }

    moveTurtle(turtle) {
        let interval = setInterval(() => {
            if (!this.isRaceOn || turtle.position >= FINISH_LINE) {
                clearInterval(interval);
                if (turtle.position >= FINISH_LINE) {
                    this.finishOrder.push(turtle.id);
                    this.updateRaceStatus(turtle);
                }
                return;
            }
            turtle.position += Math.floor(Math.random() * 10);
            this.updateTurtleStyle(turtle.id, `transform: translateX(${turtle.position}px)`);
        }, 1000);
    }

    updateTurtleStyle(turtleId, newStyle) {
        this.turtles = this.turtles.map(turtle => {
            if (turtle.id === turtleId) {
                return { ...turtle, style: newStyle };
            }
            return turtle;
        });
    }

    updateRaceStatus(turtle) {
        // Update rank and winner status
        const updatedTurtles = this.turtles.map(t => {
            if (t.id === turtle.id) {
                return { ...t, rank: this.finishOrder.length, isWinner: this.finishOrder.length === 1 };
            }
            return t;
        });
        // Update computedClass based on the new winner
        this.turtles = updatedTurtles.map(t => ({
            ...t,
            computedClass: t.isWinner ? 'result-entry winner' : 'result-entry',
        }));

        if (this.raceFinished) {
            this.isRaceOn = false;
            this.dispatchEvent(new CustomEvent('racefinished', { detail: { finishOrder: this.finishOrder } }));
        }
    }

    resetTurtlesForRace(starting = false) {
        this.turtles = this.turtles.map(turtle => ({
            ...turtle,
            position: 0,
            rank: null,
            isWinner: false,
            computedClass: 'result-entry',
            style: 'transform: translateX(0px);'
        }));
        if (!starting) {
            this.isRaceOn = false;
            this.finishOrder = [];
        }
    }

    resetRace() {
        this.resetTurtlesForRace();
    }
}
