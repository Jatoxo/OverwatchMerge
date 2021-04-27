#!mainFile "mergev2.opy"

playervar AiCheck = [null, null] #Used to check whether a player is an AI or not, if an array of length 2: not checked, if false and not an array of length 2: not an AI, if true: An Ai 


rule "Ai: Detect AI":
    @Event eachPlayer
    

    @Condition eventPlayer.hasSpawned()
    @Condition EnableAi
    @Condition len(eventPlayer.AiCheck) == 2

    #This check is based on the fact that you can't force an AI to play a different hero
    eventPlayer.AiCheck = eventPlayer.getCurrentHero()
    eventPlayer.startForcingHero(getAllHeroes()[(getAllHeroes().index(eventPlayer.getCurrentHero()) + 1) % len(getAllHeroes())])
    wait(0.02)

    if eventPlayer.getCurrentHero() == eventPlayer.AiCheck:
        eventPlayer.stopForcingCurrentHero()
        #Just a sanity check, this should never actually be triggered for players
        bigMessage(eventPlayer, "You have been deemed an Ai! If this is wrong, press F now!")

        waitUntil(eventPlayer.isHoldingButton(Button.INTERACT), 4)
        if not eventPlayer.isHoldingButton(Button.INTERACT):
            eventPlayer.AiCheck = true
            hudHeader(eventPlayer, "You are an AI", HudPosition.LEFT, 0, Color.YELLOW, HudReeval.NONE, SpecVisibility.DEFAULT)
        else:
            eventPlayer.AiCheck = false
    else:
        eventPlayer.startForcingHero(eventPlayer.AiCheck)
        eventPlayer.stopForcingCurrentHero()
        eventPlayer.AiCheck = false



rule "Ai: Merging":
    @Event eachPlayer

    #When the player has been deemed an Ai
    @Condition eventPlayer.AiCheck == true

    #This is to remove the possibility of this rule triggering when AiCheck is assigned a hero for checking
    @Condition eventPlayer.AiCheck.getCurrentHero() not in getAllHeroes()

    @Condition eventPlayer.MergeTarget != null

    if random.randint(0, 3) == 0:
        printLog("AI {0}: Merge with {1}".format(eventPlayer, eventPlayer.MergeTarget))

        wait(0.3, Wait.ABORT_WHEN_FALSE)

        eventPlayer.startForcingButton(Button.CROUCH)
        wait(0.1)
        eventPlayer.stopForcingButton(Button.CROUCH)
        


rule "Ai: Unmerging":
    @Event eachPlayer

    #When the player has been deemed an Ai
    @Condition eventPlayer.AiCheck == true

    #This is to remove the possibility of this rule triggering when AiCheck is assigned a hero for checking
    @Condition eventPlayer.AiCheck.getCurrentHero() not in getAllHeroes()

    @Condition eventPlayer.PlayerHost != null

    do:

        wait(random.randint(3, 10), Wait.ABORT_WHEN_FALSE)

    while random.randint(0, 1) == 0

    waitUntil(eventPlayer.isOnGround(), 9999)
    eventPlayer.startForcingButton(Button.CROUCH)
    wait(0.1)
    eventPlayer.stopForcingButton(Button.CROUCH)
    




