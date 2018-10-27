
function face_creating_dataset_from_camera()

    % CREATE dataset from camera
    % NOTE: Only 1 person in camera !!
    clear
    
    % SIZE
    SIZE = [144, 144];

    % Create the face detector object using Viola-Jones algorithm.
    % Refs: 
    %   https://www.vocal.com/video/face-detection-using-viola-jones-algorithm/
    %   https://en.wikipedia.org/wiki/Viola%E2%80%93Jones_object_detection_framework
    faceDetector = vision.CascadeObjectDetector();

    % Create the webcam object
    cam = webcam(1);

    % Capture one frame to get its size to set window resolution for
    % vision.VideoPlayer
    videoFrame = snapshot(cam);
    frameSize = size(videoFrame);

    % Create the video player object 
    videoPlayer = vision.VideoPlayer('Position', [100, 100 [frameSize(2), frameSize(1)] + 30]); 
    
    id = str2double(input('\n [INPUT] Id: ', 's'));
    name = input('\n [INPUT] Name: ', 's'); 

    % Create directory
    dir_path = char(strcat('dataset/', string(id), '_' , name ));
    [status, ~, ~] = mkdir(dir_path);
    if status == 1
        fprintf('\n [CREATING DIRECTORY] %s', dir_path);
    else
        fprintf('\n [WARNING] %s , creating directory is missing something !', dir_path )
    end
    
    % Initialize variables 
    isOpenWindow = true; 
    numPicGathered = 0;
    maxPicGathering = 100;  % number of pictures for gathering
    
    fprintf('\n[START] \n');
    while isOpenWindow && numPicGathered < maxPicGathering 
       
        %Get the next frame 
        videoFrame = snapshot(cam);
        videoFrameGray = rgb2gray(videoFrame);
       
        %Detection mode [x,y, w,h]
        bbox = faceDetector.step(videoFrameGray);
        fprintf(' [MODE] Detected Face \n');

        if ~isempty(bbox)
            
            numPicGathered = numPicGathered + 1 ;
            
            % Display
            videoFrame = insertObjectAnnotation(videoFrame,'rectangle',bbox,char(strcat('Scanning [' ,string(numPicGathered) ,'/100]')));
            
            % Save
            x = bbox(1);
            y = bbox(2);
            w = bbox(3);
            h = bbox(4);
            img_path = char(strcat(dir_path , '/' , string(numPicGathered) , '.png'));
            img_out = videoFrameGray(y:y+h, x:x+w);
            
            % resize to 144x144
            img_out = imresize(img_out, SIZE);
            
            imwrite(img_out, img_path);
            fprintf(' [SAVE] Picture number %d is saved !\n' , numPicGathered)
            
        end
        
        % Display the annotated video frame using the video player
        % object 
        step(videoPlayer, videoFrame);

        % Check whether the video player window has been closed 
        isOpenWindow = isOpen(videoPlayer) ; %&& isOpen(videoPlayer2);
        
    end


    % Clean up
    clear cam;
    release(videoPlayer);
    release(faceDetector);
    





end