import cv2
import os

path = "/home/kcy/Downloads/DiLiGenT/pmsData/"
class_list = os.listdir(path)

for files in class_list:

    image_folder = path + files + '/'
    video_name = files + '.avi'

    print(video_name)
    file_list = os.listdir(image_folder)
    lengh = len(file_list)

    images = [img for img in os.listdir(image_folder) if img.endswith(".png")]

    images.sort()
    images = images[:96]
    # print(images)

    frame = cv2.imread(os.path.join(image_folder, images[0]))
    height, width, layers = frame.shape

    video = cv2.VideoWriter(video_name, 0,60, (width,height))

    for image in images:
        video.write(cv2.imread(os.path.join(image_folder, image)))

    cv2.destroyAllWindows()
    video.release()
