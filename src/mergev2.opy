

#Global variables

globalvar MergeRange
globalvar Debug


#Player variables

playervar MergeTransition = false
playervar MergeTransitionAbilities = false
playervar PlayerHost
playervar StackedPlayers = []
playervar StackChanged #Incremented for every change to the stack of the player (Not a bool for sanity check in case somehow it happens twice at the same time)
playervar BlockMovement = false
playervar MergedHud = [] # Hud for the player you are connected to
playervar StackedHud = [] # Hud for the players connected to you
playervar StackedIcons = [] # Icons of the players connected to you
playervar PlayerStackIterator
playervar MovementOverrider
playervar RevealStack = false #Whether the hero stack is visible to the enemy


rule "Merge v2 - Completely rewritten from scratch by Jatoxo            ~uwu":
    #The original was a complete mess with unnamed magic variables doing magic things. The gameplay was a glitch fest too. This rewrite is well documented and should provide a highly better experience
    @Condition false == true
    

rule "Initialization":
    MergeRange = createWorkshopSetting(int[2:50], "General", "Merging Range (Meters)", 13, 0)
    Debug = createWorkshopSetting(bool, "Developer", "Debug mode", true, 0)

    
rule "Match initialization":
    @Condition (isAssemblingHeroes() or isInSetup()) == true
    
    if Debug:
        #Skips the hero assembly phase because it's annoying for debugging 
        setMatchTime(0)




#!include "targeting.opy"


#!include "mergeTriggers.opy"


#!define healthP(player) ((player.getHealth() / player.getMaxHealth()) * 100)
#!define shieldHealthP(player) ((player.getHealthOfType(Health.SHIELDS) / player.getMaxHealthOfType(Health.SHIELDS)) * 100)
#!define armorHealthP(player) ((player.getHealthOfType(Health.ARMOR) / player.getMaxHealthOfType(Health.ARMOR)) * 100)

rule "Merge: Active":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.PlayerHost != null
    
    if Debug and hostPlayer == eventPlayer:
        printLog("Merge active")

    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0, 0, 0))
    eventPlayer.MergeTransitionAbilities = true

    #Make Player invisible and unattackable
    eventPlayer.setInvisibility(Invis.ALL)
    eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
    eventPlayer.disablePlayerCollision()
    
    #Show hint on UI
    hudHeader(eventPlayer, "Connected to {0} {1}".format(eventPlayer.PlayerHost, heroIcon(eventPlayer.PlayerHost.getCurrentHero())), HudPosition.LEFT, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.DEFAULT)
    eventPlayer.MergedHud[0] = (getLastCreatedText())

    #Show Healthbar on UI
    progressBarHud(eventPlayer, healthP(eventPlayer.PlayerHost), eventPlayer.PlayerHost, HudPosition.RIGHT, 0, rgb(255, 255 - (255-50) * ((100 - healthP(eventPlayer.PlayerHost))/100), 255 * (healthP(eventPlayer.PlayerHost) / 100)), Color.WHITE, ProgressHudReeval.VALUES_AND_COLOR, SpecVisibility.DEFAULT)
    eventPlayer.MergedHud[1] = (getLastCreatedText())                                                                                                                                                       

    #Merge Effects
    playEffect(getAllPlayers(), DynamicEffect.EXPLOSION_SOUND, Color.WHITE, eventPlayer, 200)
    playEffect(getAllPlayers(), DynamicEffect.BAD_PICKUP_EFFECT, Color.WHITE, eventPlayer, 3)
    playEffect(getAllPlayers(), DynamicEffect.GOOD_PICKUP_EFFECT, Color.WHITE, eventPlayer.PlayerHost, 3)

    #Adjust Camera
    eventPlayer.stopCamera()
    #This is not doing a dot product, apparently multiplying two vectors in overwatch does a scalar multiplication on each respective dimension
    eventPlayer.startCamera(eventPlayer.getEyePosition() + vect(-3, -3, -3) * eventPlayer.getFacingDirection(), eventPlayer.getEyePosition(), 25)


rule "Merge: Inactive":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.PlayerHost == null

    if Debug and hostPlayer == eventPlayer:
        printLog("Merge not active")

    #Remove hint and healthbar on UI
    destroyHudText(eventPlayer.MergedHud[0])
    destroyProgressBarHud(eventPlayer.MergedHud[1])
    eventPlayer.MergedHud = []
    
    eventPlayer.detach()
    
    eventPlayer.setInvisibility(Invis.NONE)
    eventPlayer.clearStatusEffect(Status.PHASED_OUT)
    eventPlayer.enablePlayerCollision()
    eventPlayer.stopCamera()

rule "Re-Allow abilities after merge":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.MergeTransitionAbilities

    wait(0.2, Wait.ABORT_WHEN_FALSE)

    eventPlayer.MergeTransitionAbilities = false


rule "Merge: New host":
    @Event eachPlayer
    @Hero all
    @Condition eventPlayer.PlayerHost.PlayerHost != null

    if Debug:
        printLog("{0} switched host from {1} to {2}".format(eventPlayer, eventPlayer.PlayerHost, eventPlayer.PlayerHost.PlayerHost))

    if not eventPlayer in eventPlayer.PlayerHost.PlayerHost.StackedPlayers:
        eventPlayer.PlayerHost.PlayerHost.StackedPlayers.append(eventPlayer)
        eventPlayer.PlayerHost.PlayerHost.StackChanged++
        
    eventPlayer.PlayerHost.StackedPlayers.remove(eventPlayer)
    eventPlayer.PlayerHost.StackChanged++

    eventPlayer.PlayerHost = eventPlayer.PlayerHost.PlayerHost
    eventPlayer.attachTo(eventPlayer.PlayerHost, vect(0,0,0))

    




rule "Update Host Icons/Hud":
    @Event eachPlayer

    @Condition eventPlayer.StackChanged > 0
    
    do:
        if Debug:
            printLog("{0}: Redo Hud and Icons with new Stack".format(eventPlayer))

        #Remove all "Connected to you" texts
        while len(eventPlayer.StackedHud) > 0:
            destroyHudText(eventPlayer.StackedHud[0])
            printLog("{0}: Destroyed \"Connected to you\" text ({1})".format(eventPlayer, eventPlayer.StackedHud[0]))
            eventPlayer.StackedHud.remove(eventPlayer.StackedHud[0])
        
        #Remove all Icons on top
        while len(eventPlayer.StackedIcons) > 0:
            destroyInWorldText(eventPlayer.StackedIcons[0])
            printLog("{0}: Destroyed Icon ({1})".format(eventPlayer, eventPlayer.StackedIcons[0]))
            eventPlayer.StackedIcons.remove(eventPlayer.StackedIcons[0])

        if Debug:
            printLog("{0}: Creating icons and hud for {1}".format(eventPlayer, eventPlayer.StackedPlayers if (len(eventPlayer.StackedPlayers) > 0) else "Noone"))
            
        if len(eventPlayer.StackedPlayers) > 0:
            for eventPlayer.PlayerStackIterator in range(len(eventPlayer.StackedPlayers)):
                #!define i eventPlayer.PlayerStackIterator
                #!define currentPlayer eventPlayer.StackedPlayers[i]

                #Create "Connected to you" for every player
                hudHeader(eventPlayer, "{0} {1} is connected to you".format(currentPlayer, heroIcon(currentPlayer.getCurrentHero())), HudPosition.LEFT, 0, Color.WHITE, HudReeval.NONE, SpecVisibility.DEFAULT)
                eventPlayer.StackedHud.append(getLastCreatedText())
                if Debug:
                    printLog("{0}: Appended \"connected to you\" text({1}) for {2} to array ".format(eventPlayer, eventPlayer.StackedHud.last(), currentPlayer))

                #!define iconScale 2.5
                #Create icon for every player
                createInWorldText(getAllPlayers() if eventPlayer.RevealStack else getPlayers(eventPlayer.getTeam()), heroIcon(currentPlayer.getCurrentHero()), updateEveryTick(eventPlayer.getPosition()) + vect(0, 2 + 0.3 * i, 0), iconScale, Clip.SURFACES, WorldTextReeval.VISIBILITY_AND_POSITION, Color.WHITE, SpecVisibility.DEFAULT)
                eventPlayer.StackedIcons.append(getLastCreatedText())
                
                if Debug:
                    printLog("{0}: Appended Icon({1}) for {2} (Playing hero {3} {4}) to array ".format(eventPlayer, eventPlayer.StackedIcons.last(), currentPlayer, currentPlayer.getCurrentHero(), heroIcon(currentPlayer.getCurrentHero())))
    
        
        eventPlayer.StackChanged--
        wait(0.02)
    while eventPlayer.StackChanged > 0


rule "reveal when damaged":
    @Event eachPlayer







#!include "movement.opy"


#!include "debug.opy"


