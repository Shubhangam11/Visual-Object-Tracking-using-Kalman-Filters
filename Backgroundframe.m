function [ background_frame ] = Backgroundframe( input_video )

sample_step = 1;
vid = VideoReader(input_video);

Height = vid.height;
Width = vid.width;
nframes = vid.NumFrames; %Number of frames
background = zeros(Height,Width,3); %Initial Background Image


for i=1:sample_step:nframes-sample_step
    background = background + double(read(vid,i));
end
background = sample_step*background/(nframes);

background_frame = background;
end