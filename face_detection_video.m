
% FACE DETECTION AND TRACKING
% USING LIVE VIDEO ACQUISITION

% The face tracking system in this example 
% can be in one of two modes 
%   + detection : vision.CascadeObjectDetector to
% detect a face in the current frame -> detect 
% corner points on the face, initialize a 
% vision.PointTracker object, and then switch 
% to the tracking mode 
%   + tracking: track the points using the point
% tracker. As you track the points, some of 
% them will be lost because of occlusion. If 
% the number of points being tracked falls below 
% a threshold, that means that the face is no 
% longer being tracked. You must then switch back 
% to the detection mode to try to re-acquire the face 


%%% Sample code 


function face_detection_video()
    
    clear

    % Create the face detector object using Viola-Jones algorithm.
    % Refs: 
    %   https://www.vocal.com/video/face-detection-using-viola-jones-algorithm/
    %   https://en.wikipedia.org/wiki/Viola%E2%80%93Jones_object_detection_framework
    faceDetector = vision.CascadeObjectDetector();

    % Create the point tracker object 
    pointTracker = vision.PointTracker('MaxBidirectionalError',2);

    % Create the webcam object
    cam = webcam(1);

    % Capture one frame to get its size 
    videoFrame = snapshot(cam);
    frameSize = size(videoFrame);

    % Create the video player object 
    videoPlayer = vision.VideoPlayer('Position', [100, 100 [frameSize(2), frameSize(1)] + 30]); 
    %videoPlayer2 = vision.VideoPlayer('Position', [100, 100 [frameSize(2), frameSize(1)] + 30]); 
    
    runLoop = true; 
    numPts = 0;
    %frameCount = 0;
    pause_tmp = 0;
    
    %while runLoop && frameCount < 400 
    while runLoop
       
        %Get the next frame 
        videoFrame = snapshot(cam);
        videoFrameGray = rgb2gray(videoFrame);
        %videoFrame2 = videoFrame;
        %frameCount = frameCount + 1;
        
        if numPts < 10
           %Detection mode [x,y, w,h]
           bbox = faceDetector.step(videoFrameGray);
           fprintf(' [MODE] Detection mode \n');
           
           if ~isempty(bbox)
              % Find corner points inside the detected region  
              points = detectMinEigenFeatures(videoFrameGray, 'ROI', bbox(1,:));
              
              % Re-initialize the point tracker 
              xyPoints = points.Location;
              numPts = size(xyPoints,1);
              fprintf(' [INFO] numPts = %d \n', numPts); 
              release(pointTracker);
              initialize(pointTracker, xyPoints, videoFrameGray);
              
              % Save a copy of the points 
              oldPoints = xyPoints;
              
              % Convert the rectangle represented as [x, y, w, h]
              % into an M-by-2 matrix of [x,y] coordinates of the 
              % corners. This is needed to be able to transform 
              % the bounding box to display the orientation of 
              % the face 
              bboxPoints = bbox2points(bbox(1,:)); 
              
              % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4 y4]
              % format required by insertShape 
              bboxPolygon = reshape(bboxPoints', 1 , []);
              
              % Display a bounding box around the detected face 
              videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
              
              % Display detected corners 
              videoFrame = insertMarker(videoFrame, xyPoints, '+', 'Color', 'white');
              
           end
           
        else
            % Tracking mode.
            fprintf(' [MODE] Tracking mode \n');
            [xyPoints, isFound] = step(pointTracker, videoFrameGray);
            visiblePoints = xyPoints(isFound, :);
            oldInliers = oldPoints(isFound, :);
            
            numPts = size(visiblePoints, 1);
            fprintf(' [INFO] numPts = %d \n', numPts);
            
            if numPts >= 10 
                % Estimate the geometric transformation between the old
                % points and the new points 
                [xform, oldInliers, visiblePoints] = estimateGeometricTransform(... % ... just for enter 
                    oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
                    
                % Apply the transformation to the bounding box 
                bboxPoints = transformPointsForward(xform, bboxPoints);
                
                % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4
                % y4]
                % format required by insertShape
                bboxPolygon = reshape(bboxPoints', 1, []);
                
                % Display a bounding box around the face being tracked 
                videoFrame = insertShape(videoFrame, 'Polygon', bboxPolygon, 'LineWidth', 3);
                
                % Display tracked points 
                videoFrame = insertMarker(videoFrame, visiblePoints, '+', 'Color', 'white');
                
                % detect SURF Features  
                %boxPoints = detectSURFFeatures(videoFrameGray);
                %boxPoints = selectStrongest(boxPoints,10);
                %videoFrame2 = insertMarker(videoFrame, boxPoints.Location, '+', 'Color', 'Red');
                
                % Reset the points 
                oldPoints = visiblePoints;
                setPoints(pointTracker, oldPoints);
                
                
            end
        end
        
        % Display the annotated video frame using the video player
        % object 
        step(videoPlayer, videoFrame);
        %step(videoPlayer2, videoFrame2);

        % Check whether the video player window has been closed 
        runLoop = isOpen(videoPlayer) ; %&& isOpen(videoPlayer2);
        
    end


    % Clean up
    clear cam;
    release(videoPlayer);
    %release(videoPlayer2);
    release(pointTracker);
    release(faceDetector);
    

end