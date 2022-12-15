%% Replace bad channels by the mean of neighboring channels
% requair:
% data = (Channels x samples x trials)
% list = [1, 25, 30 .... X] list of bad channels from the tip of the neuropixel probe 
% jump_list = [1, 1, 2 ....1] replace by +- the first (1), second (2) or X neighboring channles 

function output = replace_bad_channels(data,list,jump_list)
    
    output = data;
    for i = 1:numel(list)
        BCh = list(i); %bad channel
        jump = jump_list(i); % jump to neighbor channel
        NCh = (data(BCh-jump,:,:) + data(BCh+jump,:,:))./2; %new channels 
        output(BCh,:,:) = NCh;
    end
    
end

