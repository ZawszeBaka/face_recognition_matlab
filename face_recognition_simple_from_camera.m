function face_recognition_simple_from_camera()

    clear
    SIZE = [144, 144]; % 144x144 face region of image
    
    % get the classifier 
    faceClassifier = loadCompactModel('face_recognition_classifier');
    
    % How to predict
    %[label,NegLoss,PBScore] = predict(faceClassifier,queryFeatures);

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

                x = bbox(1,1);
                y = bbox(1,2);
                w = bbox(1,3);
                h = bbox(1,4);
                
                % get max_width , max_height
                max_height = size(videoFrameGray,1);
                max_width = size(videoFrameGray,2);

                % fix exceeds matrix vertically
                if y+h > max_height
                   h = max_height - y;
                end

                % fix exceeds matrix horizontally
                if x+w > max_width
                   w = max_width - x; 
                end
                
                face_roi = videoFrameGray(y:y+h, x:x+w);
                face_roi = imresize(face_roi, SIZE);
                
                % HOG features extraction 
                hog_feature = extractHOGFeatures(face_roi);
                [name,NegLoss,PBScore] = predict(faceClassifier,hog_feature);
                fprintf(' [INFO] Recognized a face of %s , %s%\n' , char(name), string(PBScore*100) );  
                
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

                % Display
                videoFrame = insertObjectAnnotation(videoFrame,'rectangle',[x,y,w,h],char(strcat(name,' , ', string(PBScore*100), '%')));
           
              
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
                
                min_x = floor(min(bboxPoints(:,1)));
                max_x = floor(max(bboxPoints(:,1)));
                min_y = floor(min(bboxPoints(:,2)));
                max_y = floor(max(bboxPoints(:,2)));

                x = min_x;
                y = min_y;
                w = max_x - min_x;
                h = max_y - min_y;
                
                % HOG features extraction 
                if PBScore < 0.8
                    
                    % get max_width , max_height
                    max_height = size(videoFrameGray,1);
                    max_width = size(videoFrameGray,2);
                    
                    % fix exceeds matrix vertically
                    if y+h > max_height
                       h = max_height - y;
                    end
                    
                    % fix exceeds matrix horizontally
                    if x+w > max_width
                       w = max_width - x; 
                    end
                    
                    face_roi = videoFrameGray(y:y+h, x:x+w);
                    face_roi = imresize(face_roi, SIZE);
                    
                    hog_feature = extractHOGFeatures(face_roi);
                    [name,NegLoss,PBScore] = predict(faceClassifier,hog_feature);
                    fprintf(' [INFO] Recognized a face of %s , %s% \n' , char(name), string(PBScore*100) );  
                end
                    
                % Convert the box corners into the [x1 y1 x2 y2 x3 y3 x4
                % y4]
                % format required by insertShape
                bboxPolygon = reshape(bboxPoints', 1, []);
                
                % Display
                videoFrame = insertObjectAnnotation(videoFrame,'rectangle',[x,y,w,h],char(strcat(name,' , ', string(PBScore*100), '%')));
                
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
    release(pointTracker);
    release(faceDetector);
    


end