classdef Stimulus
    %STIMULI Note: this file must be in the scope of the runscript and the
    % results files in order to properly read stimuli variables and their
    % properties
    
    properties
        Text
        InkColor
        InkCode
        PrintSize
        IsCongruent
        ColorAns
        WordAns
    end
    
    methods
        function obj = Stimulus(text,inkColor,inkCode,printSize)
            switch nargin
                case 0
                    error('Stimulus: text is a required input');
                case 1
                    error('Stimulus: inkColor is a required input');
                case 2
                    error('Stimulus: inkCode is a required input');
                case 3
                    obj.Text = text;
                    obj.InkColor = inkColor;
                    obj.InkCode = inkCode;
                    obj.PrintSize = 50;
                case 4
                    obj.Text = text;
                    obj.InkColor = inkColor;
                    obj.InkCode = inkCode;
                    obj.PrintSize = printSize;
                otherwise
                    error('Stimulus: Too many input arguments');
            end
        end
        
        function drawStimulus(wPtr,obj)
            Screen('TextSize',wPtr,obj.PrintSize);
            DrawFormattedText(wPtr,obj.Text,'center','center',obj.InkCode);
        end

    end
end

