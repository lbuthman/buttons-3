trigger TreasureChestTrigger on Lead (before insert, before update, after insert, after update) {

    /** todo: when a new Treasure Chest is created, find all Opened chests (should only be one)
     *     - move all existing Active Investment Ideas to new Treasure Chest
     *     - set Treasure Chest status to Destroyed
    */

    /** todo: when an existing Treasure Chest is Opened
     *     -
    */
}