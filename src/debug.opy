#!mainFile "mergev2.opy"

rule "Debug":
    @Event eachPlayer
    @Hero all
    
    @Condition Debug
    @Condition len(eventPlayer.AiCheck) != 2
    @Condition eventPlayer.AiCheck == false


    hudHeader(eventPlayer, "Server Load: {0} %".format(getAverageServerLoad()), HudPosition.RIGHT, 0, rgb(255 * (getAverageServerLoad() / 100), 255 * (1 - getAverageServerLoad() / 100), 0), HudReeval.STRING_AND_COLOR, SpecVisibility.DEFAULT)
    hudHeader(eventPlayer, "Debug Mode is Acive!", HudPosition.RIGHT, 0, Color.YELLOW, HudReeval.STRING_AND_COLOR, SpecVisibility.DEFAULT)


    if eventPlayer == hostPlayer:
        hudHeader(eventPlayer, "Using Ability 1: {0}".format(eventPlayer.isUsingAbility1()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Using Ability 2: {0}".format(eventPlayer.isUsingAbility2()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Primary Fire: {0}".format(eventPlayer.isFiringPrimaryFire()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Secondary Fire: {0}".format(eventPlayer.isFiringSecondaryFire()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Alternate Form: {0}".format(eventPlayer.isInAlternateForm()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Using Ultimate: {0}".format(eventPlayer.isUsingUltimate()), HudPosition.LEFT, 0, Color.WHITE, HudReeval.VISIBILITY_STRING_AND_COLOR, SpecVisibility.DEFAULT)

        hudHeader(eventPlayer, "PlayerHost: {0}".format(eventPlayer.PlayerHost), HudPosition.TOP, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "PlayerHost Overrider: {0}".format(eventPlayer.PlayerHost.MovementOverrider), HudPosition.TOP, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.DEFAULT)
        hudHeader(eventPlayer, "Own Overrider: {0}".format(eventPlayer.MovementOverrider), HudPosition.TOP, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.DEFAULT)

        hudHeader(eventPlayer, "Host Distance: {0}".format(distance(eventPlayer.getPosition(), eventPlayer.PlayerHost.getPosition())), HudPosition.TOP, 0, Color.WHITE, HudReeval.STRING, SpecVisibility.DEFAULT)


