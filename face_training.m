function [classifier] = face_training()

    clear;
    
    % Read all file name in that directory
    dir_path = 'dataset';
    dir_people = dir(dir_path);
    
    first_time = true ; 
    
    % for each person 
    for i = 3:size(dir_people, 1)
        dir_person = dir_people(i).name;
        splitted_str = strsplit(dir_person, '_');
        name = char(splitted_str(2));
        
        img_paths = dir(char(strcat(dir_path, '/', dir_person)));
        
        % for each picture of that person
        for j = 3:size(img_paths, 1)
            
            img_path = char(strcat(dir_path, '/', dir_person , '/', img_paths(j).name));
            fprintf('\n [INFO] Reading image %s', img_path);
            img = imread(img_path); % actually gray color
            
            % HOG features extraction 
            hog_feature = extractHOGFeatures(img);
            
            if first_time
                X = hog_feature; 
                first_time = false;
                Y = {name};
            else
                X = cat(1, X, hog_feature); 
                Y = cat(1, Y, name); 
            end
        end
    end
    
    % Return 
    classifier = fitcecoc(X,Y);
    saveCompactModel(classifier, 'face_recognition_classifier');
    
end