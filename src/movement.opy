#!mainFile "mergev2.opy"
  

#The entire system should be refactored with an array of overriders so that longer ults for example won't get interrupted completely by a short movement
rule "Movement Override: Overrider":
    @Event eachPlayer

    #If we are overriding movement on a host
    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.MovementOverrider == eventPlayer

    printLog("YEET THE PLAYER")
    #Detach ourself
    #eventPlayer.detach() #Moved to when the ability is triggered
    wait(0.017)

    #Attach the host to us
    eventPlayer.PlayerHost.attachTo(eventPlayer, vect(0,0,0))

    waitUntil(eventPlayer.PlayerHost.MovementOverrider != eventPlayer, 9999)


    #If there is no new movement Overrider, detach the host completely
    if eventPlayer.PlayerHost.MovementOverrider == null:
        eventPlayer.PlayerHost.detach()
        wait(0.017)
    else:
        #If other player is new overrider, wait for them to attach the host to them
        wait(0.034)

    #Attach ourself back
    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))



#!define ch (eventPlayer.getCurrentHero() if eventPlayer.getHeroOfDuplication() == 0 else eventPlayer.getHeroOfDuplication())

rule "Movement: Stack - Ability 1":
    @Event eachPlayer

    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.BlockMovement == false
    @Condition eventPlayer.isUsingAbility1()
    @Condition eventPlayer.MergeTransitionAbilities == false

    @Condition ch == Hero.DOOMFIST or ch == Hero.DVA or ch == Hero.REINHARDT or ch == Hero.WINSTON or ch == Hero.ASHE or ch == Hero.ECHO or ch == Hero.GENJI or ch == Hero.MCCREE or ch == Hero.MERCY or ch == Hero.MOIRA or ch == Hero.PHARAH or ch == Hero.TRACER or ch == Hero.WIDOWMAKER
        
    printLog("Ability 1")

    eventPlayer.PlayerHost.MovementOverrider = eventPlayer

    eventPlayer.detach()

    #Some Abilities have an instant effect and will not work when triggered while attached, so cancel and immediately retrigger them after detaching
    if not ch == Hero.DVA:
        #DVA sucks and doesn't like her cooldown being set immediately, luckily she doesn't need the ability restarted in the first place
        eventPlayer.cancelPrimaryAction()
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        eventPlayer.forceButtonPress(Button.ABILITY_1)

    waitUntil(not eventPlayer.isUsingAbility1(), 99999)

    #Keep control for a little longer for a better feel and less jerkyness
    wait(0.2)

    if eventPlayer.PlayerHost.MovementOverrider == eventPlayer:
        eventPlayer.PlayerHost.MovementOverrider = null
    

rule "Movement: Host - Ability 1":
    @Event eachPlayer

    @Condition len(eventPlayer.StackedPlayers) > 0 
    @Condition eventPlayer.PlayerHost.MovementOverrider != null
    @Condition eventPlayer.isUsingAbility1()

    @Condition ch == Hero.DOOMFIST or ch == Hero.DVA or ch == Hero.REINHARDT or ch == Hero.WINSTON or ch == Hero.ASHE or ch == Hero.ECHO or ch == Hero.GENJI or ch == Hero.MCCREE or ch == Hero.MERCY or ch == Hero.MOIRA or ch == Hero.PHARAH or ch == Hero.TRACER or ch == Hero.WIDOWMAKER
        
    eventPlayer.MovementOverrider = null

    printLog("Host: Ability 1")


rule "Movement: Stack - Ultimates":
    @Event eachPlayer

    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.BlockMovement == false
    @Condition eventPlayer.isUsingUltimate()
    @Condition eventPlayer.MergeTransitionAbilities == false

    #Doomfist is a little weird, look into that later...
    @Condition ch == Hero.SIGMA or ch == Hero.MERCY

    printLog("Ultimate")

    eventPlayer.PlayerHost.MovementOverrider = eventPlayer

    eventPlayer.detach()

    waitUntil(not eventPlayer.isUsingUltimate(), 99999)

    wait(0.2)

    if eventPlayer.PlayerHost.MovementOverrider == eventPlayer:
        eventPlayer.PlayerHost.MovementOverrider = null





rule "Detect Teleports":
    @Event eachPlayer
    @Hero all
    
    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.MovementOverrider != eventPlayer
    #When the host is a certain distance away
    @Condition distance(eventPlayer.getPosition(), eventPlayer.PlayerHost.getPosition()) > 1.1

    #And maintains that distance over a short time, teleport the player
    wait(0.1, Wait.ABORT_WHEN_FALSE)

    #If the distance is small, wait longer to make sure it's not just jank
    if distance(eventPlayer.getPosition(), eventPlayer.PlayerHost.getPosition()) < 2:
        wait(0.2, Wait.ABORT_WHEN_FALSE)

    printLog("Teleport triggered by {0}".format(eventPlayer))
    if Debug:
        smallMessage(eventPlayer, "Debug: Teleport triggered, {0}".format("Blocked." if eventPlayer.PlayerHost.BlockMovement else "Teleported Host"))

  
    if eventPlayer.PlayerHost.BlockMovement == false:
        eventPlayer.PlayerHost.teleport(eventPlayer.getPosition())

    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))
  


rule "Attach to baby DVA":
    @Event eachPlayer
    @Hero all

    #When DVA loses her mech, the player stays attached to the mech, so reattach the player to baby DVA
    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.getCurrentHero() == Hero.DVA
    @Condition eventPlayer.PlayerHost.isInAlternateForm()

    printLog("Reattached {0} to baby D.VA".format(eventPlayer))
    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))


rule "Movement: Doomfist Punch":
    @Event eachPlayer
    @Hero doomfist

    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.isFiringSecondaryFire()

    waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)

    eventPlayer.PlayerHost.MovementOverrider = eventPlayer

    eventPlayer.detach()

    wait(0.55)

    if eventPlayer.PlayerHost.MovementOverrider == eventPlayer:
        eventPlayer.PlayerHost.MovementOverrider = null



rule "Movement: Brigitte Shieldbash":
    @Event eachPlayer
    @Hero brigitte

    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.isFiringPrimaryFire()

    eventPlayer.PlayerHost.MovementOverrider = eventPlayer

    eventPlayer.detach()

    waitUntil(not eventPlayer.isFiringPrimaryFire(), 99999)

    wait(0.3)

    if eventPlayer.PlayerHost.MovementOverrider == eventPlayer:
        eventPlayer.PlayerHost.MovementOverrider = null


rule "Movement: Ball Hook":
    @Event eachPlayer
    @Hero hammond

    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.isFiringSecondaryFire()

    eventPlayer.PlayerHost.MovementOverrider = eventPlayer

    eventPlayer.detach()

    waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)

    wait(0.3)

    if eventPlayer.PlayerHost.MovementOverrider == eventPlayer:
        eventPlayer.PlayerHost.MovementOverrider = null

    



