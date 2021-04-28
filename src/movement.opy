#!mainFile "mergev2.opy"

subroutine requestMovement
subroutine removeMovementRequest

rule "Movement: Stacked - Overriding":
    @Event eachPlayer

    @Condition eventPlayer.PlayerHost != null

    @Condition eventPlayer.PlayerHost.MovementStack.last() == eventPlayer

    #Detach ourself. This is also done when the player appends himself to the movementStack, but in case he gains back control after another override ended, he needs to be detached again
    eventPlayer.detach()

    #Wait, because we just detached from the host and they can not immediately attach to us
    wait(0.017)

    #Attach the host to us
    eventPlayer.PlayerHost.attachTo(eventPlayer, vect(0,0,0))

    #Wait until we are no longer the Owner of Movement, or we have unmerged
    waitUntil(eventPlayer.PlayerHost.MovementStack.last() != eventPlayer, 9999)

    if eventPlayer.PlayerHost != null:
        #Wait longer if the next movement owner is another player, because they need to wait after they detached, to attach the host to them
        if eventPlayer.PlayerHost.MovementStack.last() == eventPlayer.PlayerHost:
            wait(0.017)
        else:
            wait(0.035)

        #Attach ourself back to the Host
        eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))



rule "Movement: Host - Overriding":
    @Event eachPlayer

    @Condition len(eventPlayer.MovementStack) == 0 or eventPlayer.MovementStack.last() == eventPlayer
    @Condition eventPlayer.PlayerHost == null

    eventPlayer.detach()



#!define isPartOfStack (eventPlayer.PlayerHost != null or (len(eventPlayer.StackedPlayers) > 0))
#!define isMovementOwner ((eventPlayer.PlayerHost.MovementStack.last() == eventPlayer) if eventPlayer.PlayerHost != null else eventPlayer.MovementStack.last() == eventPlayer)
#!define ch (eventPlayer.getCurrentHero() if eventPlayer.getHeroOfDuplication() == 0 else eventPlayer.getHeroOfDuplication())

def requestMovement():
    @Name "Movement: Request Movement Owner"
    if eventPlayer.PlayerHost != null:
        eventPlayer.PlayerHost.MovementStack = eventPlayer.PlayerHost.MovementStack.exclude(eventPlayer).concat(eventPlayer)
    else:
        eventPlayer.MovementStack = eventPlayer.MovementStack.exclude(eventPlayer).concat(eventPlayer)

def removeMovementRequest():
    @Name "Movement: Remove request for Movement Owner"
    if eventPlayer.PlayerHost != null:
        eventPlayer.PlayerHost.MovementStack.remove(eventPlayer)
    else:
        eventPlayer.MovementStack.remove(eventPlayer)


rule "Movement: Ability 1":
    @Event eachPlayer

    #If we are part of a stack
    #@Condition isPartOfStack

    #If we are not already the movement owner
    @Condition not isMovementOwner
    
    @Condition eventPlayer.PlayerHost.BlockMovement == false
    @Condition eventPlayer.isUsingAbility1()
    @Condition eventPlayer.MergeTransitionAbilities == false

    @Condition ch == Hero.DOOMFIST or ch == Hero.DVA or ch == Hero.REINHARDT or ch == Hero.WINSTON or ch == Hero.ASHE or ch == Hero.ECHO or ch == Hero.GENJI or ch == Hero.MCCREE or ch == Hero.MERCY or ch == Hero.MOIRA or ch == Hero.PHARAH or ch == Hero.TRACER or ch == Hero.WIDOWMAKER
        
    requestMovement()

    if isPartOfStack:
        if Debug:
            printLog("{0} used Ability 1 while in a Stack".format(eventPlayer))
            printLog("The new MovementStack is now: {0}".format(eventPlayer.MovementStack if eventPlayer.PlayerHost == null else eventPlayer.PlayerHost.MovementStack))

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

    removeMovementRequest()

    


rule "Movement: Ultimates":
    @Event eachPlayer

    @Condition not isMovementOwner

    @Condition eventPlayer.PlayerHost.BlockMovement == false
    @Condition eventPlayer.isUsingUltimate()
    @Condition eventPlayer.MergeTransitionAbilities == false

    #Doomfist is a little weird, look into that later...
    @Condition ch == Hero.SIGMA or ch == Hero.MERCY

    printLog("{0}: Used Ultimate while in a Stack".format(eventPlayer))

    requestMovement()

    eventPlayer.detach()

    waitUntil(not eventPlayer.isUsingUltimate(), 99999)

    wait(0.2)

    removeMovementRequest()





rule "Movement: Detect Teleports":
    @Event eachPlayer
    @Hero all
    
    @Condition isPartOfStack

    
    #!define isHost (eventPlayer.PlayerHost == null)
    #!define movOwner(stackOwner) (stackOwner.MovementStack.last() if len(stackOwner.MovementStack) > 0 else stackOwner)
    #!define stackMovOwner (movOwner(eventPlayer) if isHost else movOwner(eventPlayer.PlayerHost))
    
    #When the movement Owner is a certain distance away
    @Condition distance(eventPlayer.getPosition(), stackMovOwner) > 1.2
    @Condition eventPlayer != stackMovOwner

    

    #And maintains that distance over a short time
    wait(0.1, Wait.ABORT_WHEN_FALSE)

    
    #If the distance is small, wait longer to make sure it's not just jank
    if distance(eventPlayer.getPosition(), stackMovOwner) < 7:
        wait(0.2, Wait.ABORT_WHEN_FALSE)

    if Debug:
        printLog("Teleport triggered by {0}".format(eventPlayer))
        smallMessage(eventPlayer, "Debug: Teleport triggered, {0}".format("Blocked." if eventPlayer.PlayerHost.BlockMovement else "Teleported Host"))


    #Otherwise, teleport the overrider to us (if allowed) and attach us back to him


    if eventPlayer.PlayerHost == null or (eventPlayer.PlayerHost != null and eventPlayer.PlayerHost.BlockMovement == false):
        if stackMovOwner.getCurrentHero() == Hero.HAMMOND:
            eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
            eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 2)
        stackMovOwner.teleport(eventPlayer.getPosition())


    eventPlayer.attachTo(stackMovOwner, vect(0,0,0))
  


rule "Attach to baby DVA":
    @Event eachPlayer
    @Hero all

    #When DVA loses her mech, the player stays attached to the mech, so reattach the player to baby DVA
    @Condition eventPlayer.PlayerHost != null
    @Condition eventPlayer.PlayerHost.getCurrentHero() == Hero.DVA
    @Condition eventPlayer.PlayerHost.isInAlternateForm()

    if Debug:
        printLog("Reattached {0} to baby D.VA ({1})".format(eventPlayer, eventPlayer.PlayerHost))
    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))


rule "Movement: Doomfist Punch":
    @Event eachPlayer
    @Hero doomfist

    @Condition not isMovementOwner
    @Condition eventPlayer.isFiringSecondaryFire()

    waitUntil(not eventPlayer.isFiringSecondaryFire(), 99999)

    requestMovement()

    eventPlayer.detach()

    wait(0.55)

    removeMovementRequest()



rule "Movement: Brigitte Shieldbash":
    @Event eachPlayer
    @Hero brigitte

    @Condition not isMovementOwner

    @Condition eventPlayer.isFiringSecondaryFire()
    @Condition eventPlayer.isFiringPrimaryFire()

    requestMovement()

    eventPlayer.detach()

    waitUntil(not eventPlayer.isFiringPrimaryFire(), 99999)

    wait(0.3)

    removeMovementRequest()


rule "Movement: Ball Hook":
    @Event eachPlayer
    @Hero hammond

    @Condition not isMovementOwner

    @Condition eventPlayer.isFiringSecondaryFire()

    requestMovement()

    eventPlayer.detach()

    waitUntil(not eventPlayer.isFiringSecondaryFire() or not isMovementOwner, 99999)

    #Force ball to remove his hook when he loses movement Owner 
    if eventPlayer.isFiringSecondaryFire():
        if Debug:
            printLog("unattach ball hook")
        smallMessage(eventPlayer, "Unattach")
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
        eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 2)
        

    wait(0.3)

    removeMovementRequest()

    



