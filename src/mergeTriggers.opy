#!mainFile "mergev2.opy"

subroutine triggerUnmerge
subroutine triggerMerge




rule "Merge: Activate Button":
    @Event eachPlayer
    @Hero all

    @Condition eventPlayer.MergeTarget != null

    @Condition (eventPlayer.isHoldingButton(Button.CROUCH) and not eventPlayer.MergeTransition)
    
    eventPlayer.MergeTransition = true

    triggerMerge()

    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH), 99999) 
    eventPlayer.MergeTransition = false


rule "Merge: Deactivate Button":
    @Event eachPlayer
    @Hero all
    #If the player is merged and crouches...
    @Condition eventPlayer.PlayerHost != null

    @Condition (eventPlayer.isHoldingButton(Button.CROUCH) and not eventPlayer.MergeTransition)
    

    eventPlayer.MergeTransition = true

    triggerUnmerge()

    waitUntil(eventPlayer.isHoldingButton(Button.CROUCH) == false, 99999)
    eventPlayer.MergeTransition = false


rule "Merge: Deactivate on Host Death etc..":
    @Event eachPlayer
    @Hero all

    #If the player is merged...
    @Condition eventPlayer.PlayerHost != null

    #...and the host dies or hasn't spawned
    @Condition eventPlayer.PlayerHost.isDead() or not eventPlayer.PlayerHost.hasSpawned()
    
    triggerUnmerge()


rule "Merge: Prevent merge when holding crouch when target is found..":
    @Event eachPlayer
    @Hero all

    #If the player has no target...
    @Condition eventPlayer.MergeTarget == null

    #...and is holding crouch, set mergetransition to true
    @Condition eventPlayer.isHoldingButton(Button.CROUCH)
    
    eventPlayer.MergeTransition = true

    waitUntil(not eventPlayer.isHoldingButton(Button.CROUCH), 99999)

    eventPlayer.MergeTransition = false



def triggerMerge():
    @Name "TriggerMerge"

    #eventPlayer.cancelPrimaryAction()

    eventPlayer.PlayerHost = eventPlayer.MergeTarget

    if len(eventPlayer.MovementStack) > 0:
        #Wait so our movementstack is reattached to us
        wait(0.04)
        eventPlayer.PlayerHost.MovementStack.append(eventPlayer.MovementStack)
        eventPlayer.MovementStack = []

    if Debug:
        printLog("{0}: Trigger merge with {1}".format(eventPlayer, eventPlayer.MergeTarget))

    #Add ourself to the stack of the host
    if not eventPlayer in eventPlayer.PlayerHost.StackedPlayers:
        eventPlayer.PlayerHost.StackedPlayers.append(eventPlayer)
        eventPlayer.PlayerHost.StackChanged++

    #eventPlayer.StackChanged++
    


def triggerUnmerge():
    @Name "TriggerUnmerge"

    
    if Debug:
        printLog("{0}: Trigger Unmerge from {1}".format(eventPlayer, eventPlayer.PlayerHost))

    eventPlayer.PlayerHost.StackedPlayers.remove(eventPlayer)

    eventPlayer.PlayerHost.StackChanged++

    if eventPlayer in eventPlayer.PlayerHost.MovementStack:
        eventPlayer.MovementStack = [eventPlayer]

    eventPlayer.PlayerHost.MovementStack.remove(eventPlayer)

    eventPlayer.PlayerHost = null


