function [state, boundingBox] = track(state, frame,i,v)
%TRACK Tracker function
%   This is the function you are meant to implement
%   Analyse track_ncc for a simplistic implementation sample frame;
%boundingBox = [1 1 2 2 3 3 4 4];

if(~state.initialized)
   state = initialize1(state, frame);
end
% Tracker update function to progress state and estimate bounding box.
[state, boundingBox] = sampletrack(state, frame,i,v);

end 

function [state] = initialize1(state, I)
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



function [state, boundingBox,frame1] = sampletrack(state, frame,i,v)

  frame = double(rgb2gray(frame));
 [height, width] = size(frame);
 [templateHeight, templateWidth] = size(state.template);
 r = state.position(1);
 c = state.position(2);


   if (i== 1)
      boundingBox = bounding_box(state.position,size(state.template));
        %imshow(frame);
      return;
   end

video_name = v; 
vid = VideoReader(video_name); 
nframes = vid.NumFrames;
Height = vid.Height; 
Width = vid.Width; 
thr = 10; % Threshold for generating binary image of the noise

dt=1;

A = [1 0 dt 0;
     0 1 0 dt;
     0 0 1 0 ;
     0 0 0 1 ;
     ];
B = [(dt^2)/2 (dt^2)/2 dt dt]';

% acceleration
u = 10^-2;

H = [1 0 0 0;
     0 1 0 0];
% Covariance Matrices : 

State_Uncertainty = 10;
S = State_Uncertainty * eye(size(A,1)); 
Meas_Unertainty = 1;
R = Meas_Unertainty * eye(size(H,1));


Dyn_Noise_Variance = (0.01)^2;


% Assuming the variables X and Y are independent
Q = [(dt^2)/4 0 (dt^3)/2 0;
     0 (dt^2)/4 0 (dt^3)/2;
     (dt^3/2) 0 (dt^2) 0;
     0 (dt^3)/2 0 (dt^2);
     ];


Input = [];
x = [];
Kalman_Output = [];


x = [r; c; 0.01; 0.01;];

background_frame = Backgroundframe(v);

moving = zeros(Height,Width,nframes);
labeled_frames = zeros(Height,Width,nframes);
bb=0;

 
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

    
    current_frame = double(read(vid,i));%
    % double(read(vid,i));
    moving(:,:,i) = (abs(current_frame(:,:,1) - background_frame(:,:,1)) > thr)...
                   |(abs(current_frame(:,:,2) - background_frame(:,:,2)) > thr)...
                   |(abs(current_frame(:,:,3) - background_frame(:,:,3)) > thr);
    moving(:,:,i) = bwmorph(moving(:,:,i),'erode',2);
    labeled_frames(:,:,i) = bwlabel(moving(:,:,i),4); 
    stats{i} = regionprops(labeled_frames(:,:,i),'basic');
    [n_obj,features] = size(stats{i});
    area = 0;
    if(n_obj ~= 0) 
         for k=1:n_obj
             if(stats{i}(k).Area > area)
                id(i) = k;
                area = stats{i}(k).Area;
             end
         end
    centroid(:,:,i) = stats{i}(id(i)).Centroid;
    else
        centroid(:,:,i) = [r c];
        bb = bb+1;
    end
     %indicates the frame number

    frames = read(vid,i);
%     %frames = insertShape(frames,'circle',[centroid(1,1,r) centroid(1,2,r) sqrt(stats{r}(id(r)).Area/pi)],'LineWidth',1);
     marked_noise(:,:,:,i) = frames;
%     %imshow(frames);


%f = read(v,i);
frame= read(vid,i);
frame = insertShape(frame,'rectangle',[centroid(1,1,i) centroid(1,2,i) templateWidth templateHeight],'LineWidth',2);
    %%Kalman Update
     
    % Original Tracker.
  if(mod(i,2) == 0)
        input = [centroid(1,1,i); centroid(1,2,i)];
    else
        input=[];
    end

 if isempty(x)
    x = zeros(4, 1);
    p_est = zeros(6, 6);
end  
    
    x = A*x + B*u;
    % Estimate the error covariance 
    S = A*S*A' + Q;
    % Kalman Gain Calculations
    K = S*H'*inv(H*S*H'+R);
    % Update the estimation
    if(~isempty(input)) 
        x = x + K*(input - H*x);
    end
    % Update the error covariance
    S = (eye(size(S,1)) - K*H)*S;
    % Save the measurements for plotting
    Kalman_Output = H*x;
    state.position = [Kalman_Output(2), Kalman_Output(1),];
    frame = insertShape(frame,'rectangle',[Kalman_Output(1) Kalman_Output(2) templateWidth templateHeight],'LineWidth',2,'Color','black');
    scenario_1(:,:,:,i) = frame;
    %imshow(frames);
    %writeVideo(objWrite, frames);
    boundingBox = bounding_box(state.position, size(state.template));
   
   
   %imshow(frame);
end

 
 




function [boundingBox] = bounding_box(position, size)
    r = position(1);
    c = position(2);
    w = size(2);
    h = size(1);
    boundingBox = [c-w/2 r-h/2 c+w/2 r-h/2 c+w/2 r+h/2 c-w/2 r+h/2]; 
end



