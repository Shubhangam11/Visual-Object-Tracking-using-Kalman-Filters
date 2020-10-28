function [state, boundingBox] = track_ncc(state, frame)
%TRACK NCC Tracker function
%   Ultra simplistic tracker implementation based on NCC

% Case to initialize state with parameters you need on the first iteration
if(~state.initialized)
   state = ncc_initialize(state, frame);
end
% Tracker update function to progress state and estimate bounding box.
[state, boundingBox] = ncc_update(state, frame);

end

% Initialize state
function [state] = ncc_initialize(state, I)
    state.initialized = true;
    frame = double(rgb2gray(I));
    [height, width] = size(frame);

    % Rectangular bounding box entire surrounding provided bounding polygon
    c1 = round(min(state.initialObject(1:2:end)));
    c2 = round(max(state.initialObject(1:2:end)));
    r1 = round(min(state.initialObject(2:2:end)));
    r2 = round(max(state.initialObject(2:2:end)));
    % Ensure the bounding box is in frame.
    c1 = max(1, c1);
    r1 = max(1, r1);
    c2 = min(width-2, c2);
    r2 = min(height-2, r2);
    template = frame(r1:r2, c1:c2);
    % Template of object to track
    state.template = template;
    % Center position of object to track
    state.position = [r1 + r2, c1 + c2,] / 2;
end

% Track object in subsequent frame.
function [state, boundingBox] = ncc_update(state, frame)
    frame = double(rgb2gray(frame));
    [height, width] = size(frame);
    [templateHeight, templateWidth] = size(state.template);
    r = state.position(1);
    c = state.position(2);
    % NCC region of interest around previous position
    c1 = max(1, round(c - templateWidth));
    r1 = max(1, round(r - templateHeight));
    c2 = min(width-2, round(c + templateWidth));
    r2 = min(height-2, round(r + templateHeight));
    region = frame(r1:r2, c1:c2);
    % Edge case for when the object leave the edge of the frame
    if any(size(region) < size(state.template))
        boundingBox = bounding_box(state.position, size(state.template));
        return;
    end
    % Utilize Matlab build in cross correlation on region
    C = normxcorr2(state.template, region);
    % Identify maximal correlation match
    [~, imax] = max(C(:));
    if isempty(imax)
        mc = 0;
        mr = 0;
    else
        [mr, mc] = ind2sub(size(C),imax(1));
    end
    % Aquire new template to simplistically account for a dynamic actor
    r2 = r1 + mr;
    c2 = c1 + mc;
    r1 = r2 - templateHeight;
    c1 = c2 - templateWidth;
%     template = frame(r1:r2, c1:c2);
%     state.template = template;
    % Center position of object to track
    state.position = [r1 + r2, c1 + c2,] / 2;
    % Specify bounding box in coordinate format. [x1,y1,...,x4,y4]
    boundingBox = bounding_box(state.position, size(state.template));
end

function [boundingBox] = bounding_box(position, size)
    r = position(1);
    c = position(2);
    
    w = size(2);
    h = size(1);
    boundingBox = [c-w/2 r-h/2 c-w/2 r+h/2 c+w/2 r+h/2 c+w/2 r-h/2]; 
end
