classdef PadmalaStimulus
    %STIMULI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Text
        Img
        FileName
        Reward
        RewardValue
        RewardText
        Efficacy
        PrintSize
        IsCongruent
        CorrectAns
        ImgPath         % for cue
    end
    
    methods
        function obj = PadmalaStimulus(text,img,fileName,rewardLevel)
            switch nargin
                case 0
                    error('Stimulus: text is a required input');
                case 1
                    error('Stimulus: inkColor is a required input');
                case 2
                    error('Stimulus: inkCode is a required input');
                case 3
                    error('Stimulus: rewardLevel is a required input')
                case 4
                    obj.Text = text;
                    obj.Img = img;
                    obj.FileName = fileName;
                    obj.Reward = rewardLevel;
                otherwise
                    error('Stimulus: Too many input arguments');
            end
        end
        
%         function showStimulus(wPtr,obj)
%             Screen('TextSize',wPtr,obj.PrintSize);
%             DrawFormattedText(wPtr,obj.Text,'center','center',obj.InkCode);
%             Screen(wPtr,'Flip');
%         end

    end
end

