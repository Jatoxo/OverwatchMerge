#!mainFile "mergev2.opy"

playervar ActiveStatuses = []
playervar InheritedStatuses = []

globalvar SleepPower = 1
globalvar FreezePower = 1
globalvar HackPower = 1
globalvar ShatterPower = 1
globalvar StunPower = 1


enum StatusE:
    ASLEEP,
    FROZEN,
    HACKED,
    KNOCKED_DOWN,
    STUNNED


rule "Inherit host status":
    @Event eachPlayer

    @Condition eventPlayer.PlayerHost != null

    do:

        eventPlayer.InheritedStatuses = evalOnce([eventPlayer.PlayerHost].concat(eventPlayer.PlayerHost.ActiveStatuses))

        waitUntil(eventPlayer.InheritedStatuses.slice(1, len(eventPlayer.InheritedStatuses) - 1) != eventPlayer.PlayerHost.ActiveStatuses, 99999)

        
        #!define pos eventPlayer.PlayerHost.index(eventPlayer)
        #!define isAffected(power) random.uniform(0, 99.9999) < min(100, (100/(1.5**pos)) * power)

        #If we still have a host and the host hasn't changed
        if eventPlayer.InheritedStatuses[0] == eventPlayer.PlayerHost and eventPlayer.PlayerHost != null:
             #Temporary assignement to avoid filtering the array multiple times
            eventPlayer.InheritedStatuses = [elem for elem in eventPlayer.PlayerHost.ActiveStatuses if (not elem in eventPlayer.InheritedStatuses)]

            if Debug:
                printLog("{0}: Potentially inherit status from Host({1}). Chance to inherit at power 1: {2}%".format(eventPlayer, eventPlayer.PlayerHost, min(100, (100/(1.5**pos)))))

            if StatusE.ASLEEP in eventPlayer.InheritedStatuses and isAffected(SleepPower):
                eventPlayer.setStatusEffect(null, Status.ASLEEP, 5)

            if StatusE.FROZEN in eventPlayer.InheritedStatuses and isAffected(FreezePower):
                eventPlayer.setStatusEffect(null, Status.FROZEN, 1.3)
        
            if StatusE.HACKED in eventPlayer.InheritedStatuses and isAffected(HackPower):
                eventPlayer.setStatusEffect(null, Status.HACKED, 5)
        
            if StatusE.KNOCKED_DOWN in eventPlayer.InheritedStatuses and isAffected(ShatterPower):
                eventPlayer.setStatusEffect(null, Status.KNOCKED_DOWN, 2.5)

            if StatusE.STUNNED in eventPlayer.InheritedStatuses and isAffected(StunPower):
                eventPlayer.setStatusEffect(null, Status.STUNNED, 0.8)

        wait(0.02)
    while RULE_CONDITION:
    


#!define statusChanged(status, statusE) ((not (statusE in eventPlayer.ActiveStatuses)) if eventPlayer.hasStatusEffect(status) else (statusE in eventPlayer.ActiveStatuses))
rule "Status: Apply Status to array":
    @Event eachPlayer

    @Condition statusChanged(Status.ASLEEP, StatusE.ASLEEP) or statusChanged(Status.FROZEN, StatusE.FROZEN) or statusChanged(Status.HACKED, StatusE.HACKED) or statusChanged(Status.KNOCKED_DOWN, StatusE.KNOCKED_DOWN) or statusChanged(Status.STUNNED, StatusE.STUNNED)

    if Debug:
        printLog("{0}: Status Changed".format(eventPlayer))


    if statusChanged(Status.ASLEEP, StatusE.ASLEEP):
        if eventPlayer.hasStatusEffect(Status.ASLEEP):
            eventPlayer.ActiveStatuses.append(StatusE.ASLEEP)
        else:
            eventPlayer.ActiveStatuses.remove(StatusE.ASLEEP)

    if statusChanged(Status.FROZEN, StatusE.FROZEN):
        if eventPlayer.hasStatusEffect(Status.FROZEN):
            eventPlayer.ActiveStatuses.append(StatusE.FROZEN)
        else:
            eventPlayer.ActiveStatuses.remove(StatusE.FROZEN)

    if statusChanged(Status.HACKED, StatusE.HACKED):
        if eventPlayer.hasStatusEffect(Status.HACKED):
            eventPlayer.ActiveStatuses.append(StatusE.HACKED)
        else:
            eventPlayer.ActiveStatuses.remove(StatusE.HACKED)

    if statusChanged(Status.KNOCKED_DOWN, StatusE.KNOCKED_DOWN):
        if eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN):
            eventPlayer.ActiveStatuses.append(StatusE.KNOCKED_DOWN)
        else:
            eventPlayer.ActiveStatuses.remove(StatusE.KNOCKED_DOWN)

    if statusChanged(Status.STUNNED, StatusE.STUNNED):
        if eventPlayer.hasStatusEffect(Status.STUNNED):
            eventPlayer.ActiveStatuses.append(StatusE.STUNNED)
        else:
            eventPlayer.ActiveStatuses.remove(StatusE.STUNNED)




#!define stat(status) eventPlayer.hasStatusEffect(status)
rule "Status: Apply ASLEEP to array":
    @Event eachPlayer
    @Disabled

    @Condition eventPlayer.hasStatusEffect(Status.ASLEEP)

    eventPlayer.ActiveStatuses.remove(StatusE.ASLEEP)
    eventPlayer.ActiveStatuses.append(StatusE.ASLEEP)


rule "Status: Apply FROZEN to array":
    @Event eachPlayer
    @Disabled

    @Condition eventPlayer.hasStatusEffect(Status.FROZEN)

    eventPlayer.ActiveStatuses.remove(StatusE.FROZEN)
    eventPlayer.ActiveStatuses.append(StatusE.FROZEN)


rule "Status: Apply HACKED to array":
    @Event eachPlayer
    @Disabled

    @Condition eventPlayer.hasStatusEffect(Status.HACKED)

    eventPlayer.ActiveStatuses.remove(StatusE.HACKED)
    eventPlayer.ActiveStatuses.append(StatusE.HACKED)


rule "Status: Apply KNOCKED_DOWN to array":
    @Event eachPlayer
    @Disabled

    @Condition eventPlayer.hasStatusEffect(Status.KNOCKED_DOWN)

    eventPlayer.ActiveStatuses.remove(StatusE.KNOCKED_DOWN)
    eventPlayer.ActiveStatuses.append(StatusE.KNOCKED_DOWN)


rule "Status: Apply STUNNED to array":
    @Event eachPlayer
    @Disabled

    @Condition eventPlayer.hasStatusEffect(Status.STUNNED)

    eventPlayer.ActiveStatuses.remove(StatusE.STUNNED)
    eventPlayer.ActiveStatuses.append(StatusE.STUNNED)
