function instructionsStart(p)

% Screen('TextSize',p.wPtr,40);

if p.session.isGamified
    msg = ['You will now play a game where you can earn bonus money.\n\n',...
        'Before we get started, we are going to walk you through the types of images you will see ',...
        'and give you a chance to practice the game.'];
else
    msg = ['You are going to perform a series of tasks where you will have the opportunity to earn bonus money.\n\n',...
        'We will let you know when you can earn bonus money and when it is practice.'];
end

instructions(p,msg,.5);

end

 


