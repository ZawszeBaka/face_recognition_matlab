
[=] SUMMARY : (for its detail , see below) 
- Face Detection using Viola-Jones algorithm 
- Data Gathering (144 x 144 for each face image)
- Training ( Features Extraction using Histogram of Oriented Gradient and using SVM for classifying) 
- Face Recognition and Face Tracking using KLT algorithm (can run in real-time)

### INPUT :
- Video Frames from camera
- Picture

### Stage 1: Face Detection
Viola–Jones algorithm
- Haar Cascade Classifier (pre-trained classifier) : All human faces share some similar properties.
    + Location and size: eyes , mouth , bridge of nose 
    + Value: oriented gradients of pixel intensities 
- Summed area table (Integral Image) 
- Learning algorithm 
- Cascade 
- Use the file: "face_detection_video.m"


### Stage 2: Data Gathering 
- Each face image has the fixed size 144 x 144 
- In this project, you can create dataset from pictures with conditions : each picture has only 1 potential face 
or from camera 
- Use the files "face_creating_dataset_from_camera.m" or "face_creating_dataset_from_pictures.m"


### Stage 3: Training
- Features Extraction : using Histogram of Oriented Gradients (HOG) . Ref : https://www.learnopencv.com/histogram-of-oriented-gradients/
- Classifier : using SVM for multi-class
- Use the file "face_training.m" => save Classifier to the file "face_recognition_classifier.mat"


### Stage 4: Face Recognition and Face Tracking 
- Face Recognition : load from the Classifier we have trained earlier "face_recognition_classifier.mat"
- Face Tracking : using KLT algorithm or SURF 
- Use the file "face_recognition_simple_from_camera.m"


[========================================================================================]

### How to use 
- Firstly, you should test your camera and make sure your camera works properly. Run file 'test_camera.m'
- If you want to detect face from your camera . Run file 'face_detection_video.m'
- Data Gathering: 
   + From collected images : collect images from specific person and put all of these in 1 directory in 'dataset_notyetdetect'
with requisition:   
        + Each image has only 1 potential face 
        + 'face_creating_dataset_from_pictures.m': When you run it, you need to input 3 things ( directory of collected pictures of 1 person , id of this person , name of this person) .  The process will get these images, detect a region of face and scale into the size of 144-by-144 pixels and save to 'dataset/<id>_<name>/<numPic>.png'
   + From camera (auto): 'face_creating_dataset_from_camera.m' When you run it, you only need 2 inputs ( the id and name of the person in front of camera to be labeled)
   + Note that, all pictures with fixed size 144-by-144 must be saved in directory 'dataset' . The images will be saved in different sub-directory followed by the id and name of that person . Format: 'dataset/(id)_(personName)/*.png'
- Training: You need to train the classifier . Run this file 'face_training.m'. It will train all the images of all the people in the directory 'dataset' and output the classifier to the file 'face_recognition_classifier.mat' . This output is purposed for later use 
- Face Recognition and Face Tracking: run this file 'face_recognition_simple_from_camera.m'. It will take the classifier we saved earlier and classifies for this process. 
    
### Cách sử dụng (Vietnamese Version)
! Note: mỗi lần tắt cửa sổ camera thì chương trình sẽ tự động dừng !
- Test camera trước để xem camera hoạt động ổn không. Chạy file 'test_camera.m'
- Detection face : phát hiện các khuôn mặt từ camera. Chạy file 'face_detection_video.m'
- Thu thập dữ liệu: 
    + Thu thập từ 1 nhiều hình down về từ internet:
        + Down về và lưu vào 'dataset_notyetdetected' , và đặt tên thư mục là tên của người đó
        + Label tự động và kiểm tra. Chạy file 'face_creating_dataset_from_pictures.m' cần bạn input 3 thông tin ( thư mục của những bức ảnh của 1 người mà bạn down về, id , tên của người đó) 
        + File đó sẽ lấy toàn bộ hình trong thư mục mà bạn đã nhập. Sử dụng Face Detection để tìm ra vùng chứa khuôn mặt. Resize ảnh về 144x144 và chuyển sang màu xám. Lưu vào thư mục 'dataset/(id)_(personName)/*.png' 
    + Thu thập từ camera scan 100 ảnh :
        + Input 2 thông tin: id và tên của người được labeled
        + Chạy file 'face_creating_dataset_from_camera.m' và đợi scan 100 hình 
        + Lưu vào thư mục với format 'dataset/(id)_(personName)/*.png' 
- Training:
    + Chạy 'face_training.m' để train toàn bộ hình trong thư mục 'dataset'
    + Sử dụng SVM
    + Bộ Classifier sẽ được lưu trong 'face_recognition_classifier.mat' để tiện cho dùng sau này
- Face Recognition and Face Tracking: 
    + Chạy file 'face_recognition_simple_from_camera.m' và test thử

### Status : 
- Still in developing ... 
- Please report it immediately if you see bugs , we will fix and help you !! 

### Best regards


