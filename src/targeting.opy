#!mainFile "mergev2.opy"



playervar MergeTarget
playervar MergeTargetEffects

#!define target eventPlayer.getPlayerClosestToReticle(eventPlayer.getTeam())
#!define mergeablePlayers [x for x in getPlayers(eventPlayer.getTeam()) if x != eventPlayer and x.isAlive() and x.PlayerHost == null and x in getPlayersInRadius(eventPlayer.getPosition(), MergeRange, eventPlayer.getTeam(), LosCheck.SURFACES_AND_ENEMY_BARRIERS)]
#!define betterTarget (sorted(mergeablePlayers, lambda player: angleBetweenVectors(eventPlayer.getFacingDirection(), player.getPosition() - eventPlayer.getPosition()))[0] if (len(mergeablePlayers) > 0) else null)

rule "Merge: Target Player":
    @Event eachPlayer
    @Hero all

    #If the player has spawned...
    @Condition eventPlayer.hasSpawned() == true

    #...the player isn't already merged
    @Condition eventPlayer.PlayerHost == null

    #If the target is in range...
    @Condition target in getPlayersInRadius(eventPlayer.getPosition(), MergeRange, eventPlayer.getTeam(), LosCheck.SURFACES_AND_ENEMY_BARRIERS)

    #...the target is alive...
    @Condition target.isAlive()

    #...the target isn't yourself...
    @Condition target != eventPlayer

    #...the target isn't connected to you
    @Condition target.PlayerHost != eventPlayer

    #...and not already targeted
    @Condition eventPlayer.MergeTarget != (target if target.PlayerHost == null else target.PlayerHost)


    if eventPlayer.MergeTarget != null:
        #Destroy any previous indicators
        destroyInWorldText(eventPlayer.MergeTargetEffects[0])
        eventPlayer.MergeTarget.stopForcingOutlineFor(eventPlayer)
    
    #Set currently targeted player
    eventPlayer.MergeTarget = target if target.PlayerHost == null else target.PlayerHost

    if Debug and eventPlayer == hostPlayer:
        printLog("{1}: Target player {0}".format(eventPlayer.MergeTarget, eventPlayer))

    
    #Show hint above target
    createInWorldText(eventPlayer, "Press \"{0}\" to merge!".format(buttonString(Button.CROUCH)), updateEveryTick(eventPlayer.MergeTarget.getPosition() + vect(0, 2.1, 0)), 1, Clip.SURFACES, WorldTextReeval.VISIBILITY_POSITION_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
    eventPlayer.MergeTargetEffects = [getLastCreatedText()]

    #Show an outline
    eventPlayer.MergeTarget.startForcingOutlineFor(eventPlayer, true, Color.YELLOW, OutlineVisibility.ALWAYS)




rule "Merge: Untarget Player":
    @Event eachPlayer
    @Hero all

    @Condition eventPlayer.MergeTarget != null


    #If the target is out of range, died, merged, despawned, or the player has merged, died, despawned
    @Condition (not (eventPlayer.MergeTarget in getPlayersInRadius(eventPlayer.getPosition(), MergeRange, eventPlayer.getTeam(), LosCheck.SURFACES_AND_ENEMY_BARRIERS))) or eventPlayer.MergeTarget.isDead() or eventPlayer.MergeTarget.PlayerHost != null or (not eventPlayer.MergeTarget.hasSpawned()) or eventPlayer.isDead() or eventPlayer.PlayerHost != null or (not eventPlayer.hasSpawned())


    #There is some jank with this rule where it doesn't deactive the rule condition after it executes, this should fix that
    do:
        if Debug and eventPlayer == hostPlayer:
            printLog("{1}: Untarget {0}".format(eventPlayer.MergeTarget, eventPlayer))

        #Destroy text indication above target
        destroyInWorldText(eventPlayer.MergeTargetEffects[0])

        #Remove Outline
        eventPlayer.MergeTarget.stopForcingOutlineFor(eventPlayer)

        eventPlayer.MergeTarget = null


        wait(0.02)

    
    while RULE_CONDITION

    
    


